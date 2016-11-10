module FeedHelper

  def class_for_feed_status(feed)
    if feed.fetch_success?
      'text-success'
    else
      'text-danger'
    end
  end
end