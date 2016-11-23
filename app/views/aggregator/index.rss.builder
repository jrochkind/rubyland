cache(view_cache_key) do
  xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
    xml.channel do
      xml.title("Rubyland")
      xml.link("http://www.rubyland.news")
      xml.description "news, opinion, tutorials, about ruby, aggregated"
      xml.language "en-us"
      xml.generator "https://github.com/jrochkind/rubyland"

  # <blogChannel:blogRoll>
  # http://radio.weblogs.com/0001015/userland/scriptingNewsLeftLinks.opml
  # </blogChannel:blogRoll>


      for entry in entries
        xml.item do
          xml.title(entry.title)
          xml.source(entry.feed.title, url: entry.feed.url)
          xml.description(entry.prepared_body)
          xml.pubDate(entry.datetime.utc.rfc2822)
          xml.guid(entry.entry_id, isPermalink: absolute_http_url?(entry.entry_id))
          xml.link(entry.url)
          # xml.tag!("dc:creator", item.author_name) if item_has_creator?(item)
        end
      end
    end
  end
end