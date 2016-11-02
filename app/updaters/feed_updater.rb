
class FeedUpdater
  class_attribute :max_fetch_entries
  self.max_fetch_entries = 100

  attr_reader :db_feed, :hard_refresh

  # if hard_refresh:true, then do NOT do conditional http get,
  # force a refresh.
  def initialize(db_feed, hard_refresh: false)
    raise ArgumentError("need a Feed object") unless db_feed.kind_of?(Feed)
    @db_feed = db_feed
    @hard_refresh = hard_refresh
  end

  def update
    response = fetch

    if response.status == 304
      db_feed.mark_success(:not_modified)
      db_feed.save!
      return
    end

    feed = Feedjira::Feed.parse response.to_s

    Feed.transaction do
      db_feed.http_etag = response["Etag"]
      db_feed.http_last_modified = response["Last-Modified"]

      db_feed.title = feed.title
      db_feed.description = feed.description
      db_feed.url = feed.url

      feed.entries.slice(0, max_fetch_entries).each do |entry|
        EntryUpdater.new(db_feed, entry).update
      end

      db_feed.mark_success

      db_feed.save!
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

  # Returns a http.rb resposne
  def fetch
    headers = {
      "User-Agent" => "#{HTTP::Request::USER_AGENT} (rubyland aggregator)"
    }

    unless hard_refresh
      if db_feed.http_etag
        headers["If-None-Match"] = db_feed.http_etag
      end
      if db_feed.http_last_modified
        headers['If-Modified-Since'] = db_feed.http_last_modified
      end
    end

    HTTP.headers(headers).get(feed_url)
  end

  class BadHttpStatus < StandardError
  end

end