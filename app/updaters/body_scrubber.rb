# Want to do what rails does, but with some customizations.
# Rails has a bunch of different objects involved, with kinda weird API. We try
# to use them, but with an API simpler for our custom fit.
#
#     BodyScrubber.new.sanitize(html_str)
#        # => returns nokogiri object, not string! Cause we might
#        #    want to do other things with the nokogiri, like truncate.
class BodyScrubber
  class_attribute :truncate_max_length
  self.truncate_max_length = 700

  attr_reader :base_url, :feedjira_entry

  def initialize(feedjira_entry, base_url: )
    @base_url, @feedjira_entry = base_url, feedjira_entry
    @base_url = Addressable::URI.parse(base_url)
  end

  def prepare
    str = initial_content
    return str unless str.present?

    loofah_fragment =  Loofah.fragment(initial_content)

    loofah_fragment.
      scrub!(rails_permit_scrubber).
      scrub!(RelativeUrlResolver.new(base_url: base_url))

    loofah_fragment = self.class.nokogiri_truncate(loofah_fragment, separator: ' ')

    existing_headings = []
    %w{h1 h2 h3 h4 h5 h6}.each do |potential_heading|
      if loofah_fragment.at_css(potential_heading)
        existing_headings << potential_heading
      end
    end
    if existing_headings.present? && existing_headings != ["h3"]
      loofah_fragment.scrub!(HeadingNormalizer.new(existing_headings: existing_headings))
    end

    return loofah_fragment.to_html(encoding: "UTF-8")
  end

  protected

  class HeadingNormalizer < Loofah::Scrubber
    attr_reader :existing_headings
    def initialize(options = {}, &block)
      super
      @existing_headings = options.fetch(:existing_headings)
    end

    def scrub(node)
      if level = existing_headings.index(node.name)
        node.name = "h#{level + 3}"
      end
    end
  end


  def initial_content
    # summary sounds nice, but too many feeds have lame one sentance summaries,
    # prefer content for now. Maybe later more complex heuristics.

    # No idea why feedjira is missing itunes_summary as a summary.

    # This `scrub` is ruby stdlib for removing bad UTF-8 chars
    (feedjira_entry.content.presence || feedjira_entry.summary || feedjira_entry.try(:itunes_summary)).try(:scrub)
  end

  def allowed_tags
    Rails::Html::WhiteListSanitizer.allowed_tags
  end

  def allowed_attributes
    Rails::Html::WhiteListSanitizer.allowed_attributes - Set.new(["width", "height"])
  end

  def rails_permit_scrubber
    Rails::Html::PermitScrubber.new.tap do |scrubber|
      scrubber.tags = allowed_tags
      scrubber.attributes = allowed_attributes
    end
  end

  # Some feeds have img.src and a.href that are relative links, which
  # need to be resolved to the base url.
  #
  # As long as we're traversing, we also remove 'read more' links.
  class RelativeUrlResolver < Loofah::Scrubber
    attr_reader :base_url
    def initialize(options = {}, &block)
      super
      @base_url = Addressable::URI.parse(options.fetch(:base_url))
    end

    def resolve(url)
      unless url.present? && base_url.present?
        # let's not touch an empty string or nil, although
        # I'm not completely sure that's right.
        return url
      end

      base_url.join Addressable::URI.parse(url)
    rescue Addressable::URI::InvalidURIError => e
      # not a URI at all? Um, let's strip it, I guess?
      return nil
    end

    def scrub(node)
      if node.name == "img"
        node['src'] = resolve(node['src'])
      elsif node.name == "a"
        # get rid of 'read more' links, we'll provide our own.
        if node.text.strip.downcase =~ %r{\Aread more\.*…*\z}
          node.remove
          return Loofah::Scrubber::STOP
        end

        node['href'] = resolve(node['href'])
      end
    end
  end



  # https://gist.github.com/jrochkind/3893745
  # An HTML-safe truncation using nokogiri, based off of:
  # http://blog.madebydna.com/all/code/2010/06/04/ruby-helper-to-cleanly-truncate-html.html
  #
  # but without monkey-patching, and behavior more consistent with Rails
  # truncate.
  #
  # It's hard to get all the edge-cases right, we probably mis-calculate slightly
  # on edge cases, and we aren't always able to strictly respect :separator, sometimes
  # breaking on tag boundaries instead. But this should be good enough for actual use
  # cases, where those types of incorrect results are still good enough.
  #
  # ruby 1.9 only, in 1.8.7 non-ascii won't be handled quite right.
  #
  # Pass in a Nokogiri node, probably created with Nokogiri::HTML::DocumentFragment.parse(string)
  #
  # Might want to check length of your string to see if, even with HTML tags, it's
  # still under limit, before parsing as nokogiri and passing in here -- for efficiency.
  #
  # Get back a Nokogiri node, call #inner_html on it to go back to a string
  # (and you probably want to call .html_safe on the string you get back for use
  # in rails view)
  def self.nokogiri_truncate(node, max_length: self.truncate_max_length, omission: '…', separator: nil)
    if node.kind_of?(::Nokogiri::XML::Text)
      if node.content.length > max_length
        allowable_endpoint = [0, max_length - omission.length].max
        if separator
          allowable_endpoint = (node.content.rindex(separator, allowable_endpoint) || allowable_endpoint)
        end

        ::Nokogiri::XML::Text.new(node.content.slice(0, allowable_endpoint) + omission, node.parent)
      else
        node.dup
      end
    else # DocumentFragment or Element
      return node if node.inner_text.length <= max_length

      truncated_node = node.dup
      truncated_node.children.remove
      remaining_length = max_length

      node.children.each do |child|
        if remaining_length == 0
          truncated_node.add_child ::Nokogiri::XML::Text.new(omission, truncated_node)
          break
        elsif remaining_length < 0
          break
        end
        truncated_node.add_child nokogiri_truncate(child, max_length: remaining_length, omission: omission, separator: separator)
        # can end up less than 0 if the child was truncated to fit, that's
        # fine:
        remaining_length = remaining_length - child.inner_text.length

      end
      truncated_node
    end
  end
end
