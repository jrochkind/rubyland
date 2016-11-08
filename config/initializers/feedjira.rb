# Feedburner seems to have changed their atom format, and
# feedjira isn't picking up feed url. Example feed:
# http://feeds.feedburner.com/GiantRobotsSmashingIntoOtherGiantRobots

require 'feedjira/parser/atom_feed_burner'
Feedjira::Parser::AtomFeedBurner.class_eval do
  element :link, :as => :url, :value => :href
end

