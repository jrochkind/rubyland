class FeedController < ApplicationController
  def index
    @feeds = Feed.with_latest_entry.order("UPPER(feeds.title)").all
  end

  protected

  def feeds
    @feeds
  end
  helper_method :feeds
end