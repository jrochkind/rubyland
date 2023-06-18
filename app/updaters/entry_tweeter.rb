class EntryTweeter
  TWITTER_LENGTH_LIMIT = 140

  attr_reader :entry

  def initialize(entry)
    @entry = entry
  end

  def client
    # currently using under-development tweetkit which apparently can do the Twitter
    # v2 API with Oauth that is now required  -- I don't really understand what's going
    # on under the hood, but it works.
    #
    # Don't really know if it's thread-safe, so create a new one per EntryTweeter obj
    @client ||= Tweetkit::Client.new(
      consumer_key:         ENV['TWITTER_CONSUMER_KEY'],
      consumer_secret:      ENV["TWITTER_CONSUMER_SECRET"],
      access_token:         ENV["TWITTER_ACCESS_TOKEN"],
      access_token_secret:  ENV["TWITTER_ACCESS_TOKEN_SECRET"]
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
  # raise, for instance so HoneyBadger might notice and alert. Should we?
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

    tweet_result = client.post_tweet(text: tweet_txt )

    # pretty ridiculous trying to check for success
    #
    # https://github.com/julianfssen/tweetkit/issues/15
    #
    if (tweet_result.response["status"] && tweet_result.response["status"] != 200) || tweet_result.response["data"].blank?
      error_log("Did not succesfully tweet entry #{entry.id}, #{tweet_result.response}")
      return false
    end


    tweet_id = tweet_result.response&.dig("data", "id")
    entry.update!(tweet_id: (tweet_id || "could_not_find"))

    if tweet_id.blank?
      error_log("Could retrieve_tweet_id for entry #{entry.id} from #{tweet_result.response}")
      return false
    end

    return true
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
