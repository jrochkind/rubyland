class Updater

  def update_feed_ids(feed_ids)
    update_in_scope(Feed.where(id: feed_ids))
  end

  def update_all
    update_in_scope(Feed)
  end

  protected

  def update_in_scope(scope)
    scope.find_each do |feed|
      begin 
        FeedUpdater.new(feed).update
      rescue StandardError => e
        Rails.logger.error("Could not update #{feed.feed_url}, #{e}")
        raise e
      end
    end
  end
end