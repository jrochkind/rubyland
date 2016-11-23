class AggregatorController < ApplicationController
  def index
    if Rails.env.production? || ENV['HTTP_CACHING']
      fresh_when etag: etag
    end
  end

  protected

  def entries
    # start_of_day keeps our condition from changing every second,
    # for cacheability.
    earliest_time = Time.now.utc.beginning_of_day - 3.months
    @entries ||= Entry.includes(:feed).order("datetime desc, created_at desc").where("updated_at > ?", earliest_time).limit(110)
  end
  helper_method :entries

  def titles_only?
    !! params[:titles_only]
  end
  helper_method :titles_only?

  def view_cache_key
    # cache so the view doesn't have to look it up again, although
    # I think entries.cache_key would prob be cached anyway, but not certain.
    @view_cache_key ||= [request.format, titles_only?, entries.cache_key]
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

  def absolute_http_url?(str)
    Addressable::URI.parse(str).try { |u| %w{http https}.include?(u.scheme) }
  rescue Addressable::URI::InvalidURIError
    return false
  end
  helper_method :absolute_http_url?

end