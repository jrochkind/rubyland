class FeedController < ApplicationController
  def index
    @feeds = Feed.order(:title).all
  end

  protected

  def feeds
    @feeds
  end
  helper_method :feeds
end