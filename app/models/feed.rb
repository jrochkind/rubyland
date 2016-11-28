class Feed < ApplicationRecord
  enum status: %w{suggested approved rejected suspended}.collect { |a| [a,a] }.to_h

  enum fetch_status: %w{not_yet_attempted ok not_modified error}.collect { |a| [a,a] }.to_h,  
    _prefix: 'fetch'
  # note, enum above will creates scopes Feed.fetch_error etc

  scope :fetch_success, -> { where(fetch_status: %w{ok not_modified}) }

  scope :with_latest_entry, -> { select("feeds.*, entries.datetime AS latest_entry_datetime, entries.title AS latest_entry_title, entries.url AS latest_entry_url").left_outer_joins(:entries).where('entries.datetime is null OR entries.datetime = (SELECT MAX(entries.datetime) FROM entries WHERE entries.feed_id = feeds.id)') }

  has_many :entries, dependent: :destroy

  validates :feed_url, presence: true

  def fetch_success?
    fetch_ok? || fetch_not_modified?
  end

  def mark_success(status = :ok)
    # no idea why self is needed here??
    self.last_fetch_at = Time.now
    self.fetch_status = status
    self.fetch_error_info = nil
  end

  def mark_failed(exception: nil)
    self.last_fetch_at = Time.now
    self.fetch_status = :error
    self.fetch_error_info = serialize_error_info(exception)
  end



  protected

  def serialize_error_info(exception)
    {
      class_name: exception.class.name,
      message: exception.message,
      backtrace: exception.backtrace
    }
  end

end