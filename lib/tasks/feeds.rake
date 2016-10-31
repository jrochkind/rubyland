namespace :feeds do
  desc "load feeds from a file"
  task :seed => :environment do
    File.open(ENV["FILE"] || Rails.root + "seed_feeds.txt") do |file|
      file.each_line do |url|
        url = (url || "").chomp.sub(%r{\#.*\z}, '').strip
        next if url.blank?

        Feed.find_or_create_by!(feed_url: url)
      end
    end
  end

  desc "update feeds"
  task :update => :environment do
    if ENV["FEED_ID"].present?
      Updater.new.update_feed_ids(ENV["FEED_ID"].split(",").collect(&:to_i))
    else
      Updater.new.update_all
    end
  end

end