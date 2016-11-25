class EntryTweetId < ActiveRecord::Migration[5.0]
  def change
    add_column :entries, :tweet_id, :string
  end
end
