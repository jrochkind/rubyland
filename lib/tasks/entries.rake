namespace :entries do
  desc "truncate to newest 5500 entries and run ANALYZE"
  task :truncate => :environment do
    oldest_to_keep = Entry.order(updated_at: :desc).offset(5500).pluck(:updated_at).first
    Entry.where("updated_at < ?", oldest_to_keep).delete_all

    # And run a postgres analyze to keep heroku happy
    Entry.connection.execute("ANALYZE #{Entry.table_name}")
  end
end
