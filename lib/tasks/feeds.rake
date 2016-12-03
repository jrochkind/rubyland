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
    # default refresh blank, twitter_update true.
    updater = Updater.new(refresh: (ENV['REFRESH'] ? ENV['REFRESH'].to_sym : :conditional),
                          twitter_update: ENV['TWITTER_UPDATE'] != "false")

    if ENV["FEED_ID"].present?
      updater.update_feed_ids(ENV["FEED_ID"].split(",").collect(&:to_i))
    elsif ENV["FEED_SEARCH"].present?
      feed_ids = Feed.where("feed_url like :regex OR title like :regex", regex: '%' + ENV["FEED_SEARCH"] + '%').pluck(:id)
      updater.update_feed_ids(feed_ids)
    else
      updater.update_all
    end
  end

  desc "show feeds"
  task :show => :environment do
    pp Feed.where("feed_url like :regex OR title like :regex", regex: '%' + ENV["FEED_SEARCH"] + '%').all
  end

  desc "add feed by feed_url"
  task :add, [:feed_url] => :environment do |t, args|
    pp Feed.create!(feed_url: args[:feed_url])
  end

  desc "delete feed by ID"
  task :delete, [:feed_id] => :environment do |t, args|
    Feed.find(args[:feed_id]).destroy
  end

end