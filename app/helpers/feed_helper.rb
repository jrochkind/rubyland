module FeedHelper

  def class_for_feed_status(feed)
    if feed.last_fetch_success?
      'text-success'
    else
      'text-danger'
    end
  end
end