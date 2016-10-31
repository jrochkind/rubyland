

class EntryUpdater
  attr_reader :db_feed, :feedjira_entry
  def initialize(db_feed, feedjira_entry)
    @db_feed, @feedjira_entry = db_feed, feedjira_entry
  end

  def update
    db_entry = Entry.find_or_initialize_by(feed: db_feed, entry_id: feedjira_entry.entry_id)

    db_entry.title = feedjira_entry.title.try(:scrub)
    db_entry.url = feedjira_entry.url.try(:scrub)
    db_entry.prepared_body = prepare_body(feedjira_entry)

    db_entry.datetime = feedjira_entry.published || db_entry.datetime || feedjira_entry.last_modified || Time.now

    db_entry.save!
  end

  def prepare_body(feedjira_entry)
    BodyScrubber.new(db_feed, feedjira_entry).prepare
  end
end