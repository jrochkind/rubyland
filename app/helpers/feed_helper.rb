module FeedHelper

  def class_for_feed_status(feed)
    if feed.fetch_success?
      ''
    else
      'text-danger'
    end
  end

  def rss_body(entry)
    label = "Originally appeared on ".html_safe + link_to(entry.feed.title, entry.feed.url) + ".".html_safe
    content_tag(:p, label, class: "rubyland-attribution", data: { rubyland_attribution: true }) +
      entry.prepared_body.html_safe
  end

end