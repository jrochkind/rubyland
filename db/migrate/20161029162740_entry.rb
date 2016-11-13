class Entry < ActiveRecord::Migration[5.0]
  def change
    create_table :entries do |t|
      t.string :entry_id, indexed: true, null: false
      t.string :title
      t.text :prepared_body
      t.string :url

      t.datetime :datetime

      t.references :feed

      t.timestamps
    end
  end
end
