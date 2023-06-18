
class FeedUpdater
  class_attribute :max_fetch_entries
  self.max_fetch_entries = 100

  class_attribute :max_redirects
  self.max_redirects = 8

  attr_reader :db_feed, :refresh, :twitter_update

  # if refresh: :hard, then do NOT do conditional http get,
  # force a refresh.
  def initialize(db_feed, refresh: :conditional, twitter_update: false)
    raise ArgumentError.new("need a Feed object") unless db_feed.kind_of?(Feed)
    @db_feed = db_feed
    @refresh = refresh
    @twitter_update = twitter_update
  end

  def update
    response, new_url = fetch

    db_feed.feed_url = new_url if new_url

    if response.status == 304 # not_modified
      db_feed.mark_success(:not_modified)
      db_feed.save!
      return
    end

    feed = Feedjira.parse response.to_s

    db_feed.http_etag = response["Etag"]
    db_feed.http_last_modified = response["Last-Modified"]

    db_feed.title = feed.title
    db_feed.description = feed.description

    # some feeds use relative urls! so wrong ruby together.
    # And some return a feed.url with newlines and empty space in them, grr devonestes
    if feed.url.present?
      db_feed.url = Addressable::URI.parse(db_feed.feed_url) + Addressable::URI.parse(feed.url.try(:strip))
    end

    entries = feed.entries.slice(0, max_fetch_entries).collect do |entry|
      EntryUpdater.new(db_feed, entry).build
    end

    # Some feeds are giving us duplicate id's, standards violating. le sigh,
    # we'll just silently skip one
    entries.uniq! { |e| e.entry_id }

    Feed.transaction do
      entries.each(&:save)
      db_feed.mark_success
      db_feed.save!
    end

    if twitter_update
      entries.each do |entry|
        EntryTweeter.new(entry).update if entry.tweet_id.blank? && (entry.datetime > Time.now - 3.days)
      end
    end

  rescue StandardError => e
    db_feed.restore_attributes
    db_feed.mark_failed(exception: e)
    db_feed.save!
    return false
  end

  def feed_url
    db_feed.feed_url
  end

  def prepare_body(feedjira_entry)
    santize(content)
  end

  # Returns a http.rb response, and a (new url or nil)
  def fetch
    headers = {
      "User-Agent" => "#{HTTP::Request::USER_AGENT} (rubyland aggregator)"
    }

    unless refresh == :hard
      if db_feed.http_etag
        headers["If-None-Match"] = db_feed.http_etag
      end
      if db_feed.http_last_modified
        headers['If-Modified-Since'] = db_feed.http_last_modified
      end
    end

    # Loop redirects, marking new permanent url if all 304s
    tries = 0
    fetch_url = feed_url
    new_url = nil
    response = nil
    permanent_new_url = nil
    all_301s = true

    while tries < max_redirects
      tries += 1
      response = HTTP.use(:auto_inflate).headers(headers).get(fetch_url)

      if HTTP::Redirector::REDIRECT_CODES.include? response.status
        if response.status != 301
          all_301s = false
        end
        fetch_url = response.headers["Location"]
      else
        break
      end
    end

    return response, (tries > 1 && all_301s ? fetch_url : nil)
  end

  class BadHttpStatus < StandardError
  end

end
