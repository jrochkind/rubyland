class Feed < ActiveRecord::Migration[5.0]
  def change
    create_table :feeds do |t|
      t.string :title
      t.string :description
      t.string :feed_url, index: true, uniq: true
      t.string :url

      t.datetime :last_fetch_at
      t.string :fetch_status, default: "not_yet_attempted"
      t.json :fetch_error_info

      t.string :http_etag
      t.string :http_last_modified

      t.timestamps
    end
  end
end
