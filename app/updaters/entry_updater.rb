

class EntryUpdater
  attr_reader :db_feed, :feedjira_entry
  def initialize(db_feed, feedjira_entry)
    @db_feed, @feedjira_entry = db_feed, feedjira_entry
  end

  def build
    db_entry = Entry.find_or_initialize_by(feed: db_feed, entry_id: feedjira_entry.entry_id)

    db_entry.title = feedjira_entry.title.try(:scrub)
    db_entry.url = get_url(feedjira_entry)
    db_entry.prepared_body = prepare_body(feedjira_entry, base_url: db_entry.url)

    set_datetime(db_entry, feedjira_entry)

    db_entry
  end

  def update
    db_entry = build
    db_entry.save!
  end

  protected

  def get_url(feedjira_entry)
    url = feedjira_entry.url.try(:scrub)
    # Some feeds delivery entries actually missing the url
    return nil unless url

    # some feeds use relative urls! so wrong ruby together.
    parsed = Addressable::URI.parse(url)

    if parsed.host.blank?
      url = Addressable::URI.parse(db_feed.feed_url) + parsed
    end

    return url
  end

  def set_datetime(db_entry, feedjira_entry)
    # prefer `published`, if we have one update it if it changes. Otherwise, use last_modified
    # or Now, but cache first one forever.

    published = feedjira_entry.published.try do |date|
      # If it has 00:00:00 GMT time, it probably doesn't really have a time, if it's TODAY
      # give it present time so it will sort better/more recent.
      now = Time.now.utc
      if [date.hour, date.min, date.sec] == [0,0,0] && now.to_date == date.utc.to_date
        Time.utc(date.year, date.month, date.day,
                 now.hour, now.min, now.sec)
      else
        date
      end
    end

    datetime = feedjira_entry.published || db_entry.datetime || feedjira_entry.last_modified

    # Still don't have it? Stupid workaround for rubytogether's lack of date but embedding it
    # in id, gah.
    if datetime.nil? && feedjira_entry.entry_id =~ /(\d\d\d\d)-(\d\d)-(\d\d)/
      year, month, date = $1.to_i, $2.to_i, $3.to_i
      if (2015..2100).cover?(year) && (1..12).cover?(month) && (1..31).cover?(date)
        datetime = Date.new(year, month, date)
      end
    end

    # last resort
    datetime ||= Time.now

    db_entry.datetime = datetime
  end

  def prepare_body(feedjira_entry, base_url: )
    BodyScrubber.new(feedjira_entry, base_url: base_url).prepare
  end
end