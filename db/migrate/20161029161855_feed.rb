class Feed < ActiveRecord::Migration[5.0]
  def change
    create_table :feeds do |t|
      t.string :title
      t.string :description
      t.string :feed_url, index: true, uniq: true
      t.string :url
      t.datetime :last_modified
      t.timestamps
    end
  end
end
