cache(view_cache_key) do
  xml.rss("version" => "2.0", 
          "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
          "xmlns:blogChannel" => "http://backend.userland.com/blogChannelModule") do
    xml.channel do
      xml.title("Rubyland")
      xml.link("http://www.rubyland.news")
      xml.description "news, opinion, tutorials, about ruby, aggregated"
      xml.language "en-us"
      xml.generator "https://github.com/jrochkind/rubyland"

      xml.tag!("blogChannel:blogRoll", sources_url(format: "opml"))

      for entry in entries
        xml.item do
          xml.title(entry.title)
          xml.source(entry.feed.title, url: entry.feed.url)
          xml.description(entry.prepared_body)
          xml.pubDate(entry.datetime.utc.rfc2822)
          xml.guid(entry.entry_id, isPermaLink: absolute_http_url?(entry.entry_id))
          xml.link(entry.url)
          # xml.tag!("dc:creator", item.author_name) if item_has_creator?(item)
        end
      end
    end
  end
end