class Updater

  def update_all
    Feed.find_each do |feed|
      begin
        FeedUpdater.new(feed).update
      rescue StandardError => e
        Rails.logger.error("Could not update #{feed.feed_url}, #{e}")
        raise e
      end
    end
  end

end