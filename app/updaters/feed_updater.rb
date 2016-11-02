
class FeedUpdater
  attr_reader :db_feed
  def initialize(db_feed)
    raise ArgumentError("need a Feed object") unless db_feed.kind_of?(Feed)
    @db_feed = db_feed
  end

  def update
    response = HTTP.get(feed_url)

    feed = Feedjira::Feed.parse response.to_s

    Feed.transaction do
      db_feed.http_etag = response["Etag"]
      db_feed.http_last_modified = response["Last-Modified"]

      db_feed.title = feed.title
      db_feed.description = feed.description
      db_feed.url = feed.url

      feed.entries.each do |entry|
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

  class BadHttpStatus < StandardError
  end

end