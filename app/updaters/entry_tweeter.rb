class EntryTweeter
  TWITTER_LENGTH_LIMIT = 280

  attr_reader :entry

  def initialize(entry)
    @entry = entry
  end

  def client
    # https://github.com/sferik/x-ruby  with v2 twitter/x api
    #
    # I think it's thread-safe so we could be creating a global obj, but
    # for now one per EntryTweeter instance
    @client ||= X::Client.new(
      api_key:         ENV['TWITTER_CONSUMER_KEY'] || ENV['X_API_KEY'],
      api_key_secret:      ENV["TWITTER_CONSUMER_SECRET"] || ENV['X_API_KEY_SECRET'],
      access_token:         ENV["TWITTER_ACCESS_TOKEN"] || ENV['X_ACCESS_TOKEN'],
      access_token_secret:  ENV["TWITTER_ACCESS_TOKEN_SECRET"] || ENV['X_ACCESS_TOKEN_SECRET']
    )
  end

  def credentials?
    client.token_auth?
  end

  # We go through some contortions to our best never to duplicate-tweet the same
  # entry.  Something going wrong and spamming the same content over and over
  # would be very bad, we err on the side of not tweeting if anything looks amiss.
  #
  # We try to log lots of errors resulting no tweet made -- we do not currently ever
  # raise, so at present for instance HoneyBadger will not notice and alert. Should we?
  def update
    unless credentials?
      error_log("We don't seem to have credentails to tweet entry #{entry.id}")
      return false
    end

    if entry.tweet_id.present?
      error_log("entry #{entry.id} may have already been tweeted, tweet_id=='#{entry.tweet_id}', not retweeting")
      return false
    end

    # cheesy way to try and avoid any race condition
    reserved = Entry.where(id: entry.id, tweet_id: nil).update(tweet_id: "in_progress").count
    unless reserved == 1
      error_log("Entry #{entry.id} in state where a possible retweet could happen, refusing to tweet. entry.tweet_id=='#{entry.tweet_id}'")
      return false
    end

    tweet_result = client.post("tweet", { text: tweet_txt })

    tweet_id = tweet_result&.dig("data", "id")

    if tweet_id.blank?
      error_log("Could retrieve_tweet_id for entry #{entry.id} from #{tweet_result.response}")
      return false
    end

    entry.update!(tweet_id: (tweet_id || "could_not_find"))

    return true
  rescue X::Error => e
    error_log("Did not succesfully tweet entry #{entry.id}, #{e.class}: #{e.message}")
    return false
  end

  def tweet_txt
    "#{entry.feed.title} ➜ #{limited_title} #{entry.url}"
  end

  def limited_title
    limit = TWITTER_LENGTH_LIMIT - (entry.feed.title.unicode_normalize.length + 4 + 26)
    entry.title.truncate(limit, omission: "…", separator: " ")
  end

  def error_log(msg)
    Rails.logger.error("#{self.class}: #{msg}")
  end
end
