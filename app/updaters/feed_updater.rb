
class FeedUpdater
  attr_reader :db_feed
  def initialize(db_feed)
    raise ArgumentError("need a Feed object") unless db_feed.kind_of?(Feed)
    @db_feed = db_feed
  end

  def update
    feed = Feedjira::Feed.fetch_and_parse feed_url

    Feed.transaction do
      db_feed.title = feed.title
      db_feed.description = feed.description
      db_feed.url = feed.url

      feed.entries.each do |entry|
        EntryUpdater.new(db_feed, entry).update
      end

      db_feed.last_modified = feed.last_modified
      db_feed.save!
    end
  end

  def feed_url
    db_feed.feed_url
  end

  def prepare_body(feedjira_entry)
    santize(content)
  end

end