module FeedHelper

  def class_for_feed_status(feed)
    if feed.fetch_success?
      ''
    else
      'text-danger'
    end
  end
end