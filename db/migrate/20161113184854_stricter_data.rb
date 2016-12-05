class StricterData < ActiveRecord::Migration[5.0]
  def change
    change_column_null :feeds, :feed_url, false
    remove_index :feeds, :feed_url
    add_index :feeds, :feed_url, unique: true

    add_index :entries, :entry_id, unique: true
  end
end
