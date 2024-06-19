class FeedController < ApplicationController
  def index
    if Rails.env.production? || ENV['HTTP_CACHING']
      fresh_when etag: etag
    end
  end

  protected

  # Can't do a count on our 'with_latest_entry' join, so...
  def base_feeds
    @base_feeds ||= Feed.order("UPPER(feeds.title)")
  end

  def feed_count
    @feed_count ||= base_feeds.count
  end
  helper_method :feed_count

  def feeds
    @feeds ||= base_feeds.with_latest_entry
  end
  helper_method :feeds

  def view_cache_key
    # cache so the view doesn't have to look it up again, although
    # I think entries.cache_key would prob be cached anyway, but not certain.
    @view_cache_key ||= [request.format.to_s, Feed.order(updated_at: :desc).first.updated_at.utc.rfc3339]
  end
  helper_method :view_cache_key

  def etag
    # add the heroku SOURCE_VERSION to our etag, so we get
    # a new etag on every deploy. We could try to access the way
    # Rails does template dependency fingerprinting, but it misses
    # a lot of things, and involves kind of reverse engineering Rails.
    # This is pretty decent.
    [ENV['SOURCE_VERSION']] + view_cache_key
  end
end
