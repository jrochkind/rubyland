class FeedStatus < ActiveRecord::Migration[5.0]
  def change
    add_column :feeds, :status, :string, default: "suggested"
    add_index :feeds, :status
    reversible do |dir|
      dir.up { Feed.update_all(status: "approved")  }
    end
  end
end
