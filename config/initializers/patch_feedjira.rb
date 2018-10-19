class Feedjira::Parser::Atom
  # monkey-patch to allow xmlns=https://www.w3.org/2005/Atom , even though
  # the `https` actually violates Atom as not a good namespace,
  # https://idiosyncratic-ruby.com/feed.xml does it anyway, let's allow it.
  def self.able_to_parse?(xml)
    %r{\<feed[^\>]+xmlns\s?=\s?[\"\'](http(s?)://www\.w3\.org/2005/Atom|http://purl\.org/atom/ns\#)[\"\'][^\>]*\>} =~ xml # rubocop:disable Metrics/LineLength
  end
end
