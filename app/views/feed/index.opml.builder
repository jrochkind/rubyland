cache(view_cache_key) do
  xml.opml("version" => "1.1") do
    xml.head do
      xml.title "Rubyland Sources"
      xml.dateCreated Date.new(2016, 11, 16).to_datetime.utc.rfc2822
      xml.dateModified feeds.order("updated_at desc").first.updated_at.utc.rfc2822
      xml.ownerName "Jonathan Rochkind"
      xml.ownerEmail "jonathan@rubyland.news"
    end
    xml.body do
      feeds.each do |feed|
        xml.outline text: feed.title, xmlUrl: feed.feed_url, url: feed.url
      end
    end
  end
end