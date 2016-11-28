class EntryTweeter
  TWITTER_LENGTH_LIMIT = 140

  attr_reader :entry

  def initialize(entry)
    @entry = entry
  end

  def client
    # Don't really know if it's thread-safe, so create a new one per EntryTweeter obj
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
  end

  def credentials?
    client.credentials?
  end

  def update
    if credentials? && entry.tweet_id.nil?
      # cheesy way to try and avoid any race condition, although it
      # doesn't warn us if something gets stuck in `in_progress`
      # forever
      reserved = Entry.where(id: entry.id, tweet_id: nil).update(tweet_id: "in_progress").count
      return unless reserved == 1

      response = client.update( tweet_txt )
      entry.update(tweet_id: response.id)
      return true
    end
  end

  def tweet_txt
    "#{entry.feed.title} ▶ #{limited_title} #{entry.url}"
  end

  def limited_title
    limit = TWITTER_LENGTH_LIMIT - (entry.feed.title.unicode_normalize.length + 4 + 26)
    entry.title.truncate(limit, omission: "…", separator: " ")
  end
end