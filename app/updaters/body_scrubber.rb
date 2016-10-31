# Want to do what rails does, but with some customizations.
# Rails has a bunch of different objects involved, with kinda weird API. We try
# to use them, but with an API simpler for our custom fit.
#
#     BodyScrubber.new.sanitize(html_str)
#        # => returns nokogiri object, not string! Cause we might
#        #    want to do other things with the nokogiri, like truncate.
class BodyScrubber
  attr_reader :feed, :feedjira_entry

  def initialize(feed, feedjira_entry )
    @feed, @feedjira_entry = feed, feedjira_entry
  end

  def prepare
    str = initial_content
    return str unless str.present?

    loofah_fragment =  Loofah.fragment(initial_content)

    loofah_fragment.
      scrub!(rails_permit_scrubber).
      scrub!(BadUrlScrubber)

    return loofah_fragment.to_html(encoding: "UTF-8")
  end

  protected

  def initial_content
    # summary sounds nice, but too many feeds have lame one sentance summaries,
    # prefer content for now. Maybe later more complex heuristics. 

    # This `scrub` is ruby stdlib for removing bad UTF-8 chars
    (feedjira_entry.content.presence || feedjira_entry.summary).try(:scrub)
  end

  def allowed_tags
    Rails::Html::WhiteListSanitizer.allowed_tags
  end

  def allowed_attributes
    Rails::Html::WhiteListSanitizer.allowed_attributes
  end

  def rails_permit_scrubber
    Rails::Html::PermitScrubber.new.tap do |scrubber|
      scrubber.tags = allowed_tags
      scrubber.attributes = allowed_attributes
    end
  end

  # Some feeds have img.src and a.href that are relative links, which is
  # just useless in a feed, they're now relative to us, and wrong.
  # Remove em with loofah.
  #
  # This does a few other things too, to be efficient with one loofah pass-through.
  # Loofah's documented API does not lead to very readable code, sorry...
  BadUrlScrubber = Loofah::Scrubber.new do |node|
    if node.name == "img"
      src = node.attr("src")
      unless src.present? && Addressable::URI.parse(src).scheme.present?
        node.remove
        Loofah::Scrubber::STOP
      end
    elsif node.name == "a"
      # get rid of 'read more' links, we'll provide our own.
      if node.text.strip.downcase =~ %r{\Aread more\.*…*\z}
        node.remove
        Loofah::Scrubber::STOP
      else # remove relative href's
        href_attr = node.attr("href")
        if href_attr && ! Addressable::URI.parse(href_attr.to_s).scheme.present?
          href_attr.remove
        end
      end
    end
  end

end