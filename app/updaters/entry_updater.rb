

class EntryUpdater
  attr_reader :db_feed, :feedjira_entry
  def initialize(db_feed, feedjira_entry)
    @db_feed, @feedjira_entry = db_feed, feedjira_entry
  end

  def build
    # some feeds illegally do not include an id, bah, we'll use the url if we can.
    db_entry = Entry.find_or_initialize_by(feed: db_feed, entry_id: feedjira_entry.entry_id || feedjira_entry.url)

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
    # Previous version let feeds update their published date, but
    # for now more important to assign some minutes to 00:00:00 ones,
    # haven't combined em both yet. 
    return db_entry if db_entry.datetime

    date = feedjira_entry.published || feedjira_entry.last_modified

    date = date.try do |date|
      # If it has 00:00:00 GMT time, it probably doesn't really have a time, if it's TODAY
      # give it present time so it will sort better/more recent.
      now_utc = Time.now.utc
      now_pacific = Time.now.in_time_zone("Pacific Time (US & Canada)")
      now_eastern = Time.now.in_time_zone("Eastern Time (US & Canada)")
      if [date.hour, date.min, date.sec] == [0,0,0] && [now_utc.to_date, now_eastern.to_date, now_pacific.to_date].include?(date.utc.to_date)
        now_utc
      else
        date
      end
    end

    # Still don't have it? Stupid workaround for rubytogether's lack of date but embedding it
    # in id, gah.
    if date.nil? && feedjira_entry.entry_id =~ /(\d\d\d\d)-(\d\d)-(\d\d)/
      year, month, date = $1.to_i, $2.to_i, $3.to_i
      if (2015..2100).cover?(year) && (1..12).cover?(month) && (1..31).cover?(date)
        date = Date.new(year, month, date)
      end
    end

    # last resort
    date ||= Time.now

    db_entry.datetime = date

    return db_entry
  end

  def prepare_body(feedjira_entry, base_url: )
    BodyScrubber.new(feedjira_entry, base_url: base_url).prepare
  end
end