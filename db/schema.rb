# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161113184854) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "entries", force: :cascade do |t|
    t.string   "entry_id",      null: false
    t.string   "title"
    t.text     "prepared_body"
    t.string   "url"
    t.datetime "datetime"
    t.integer  "feed_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.index ["entry_id"], name: "index_entries_on_entry_id", unique: true, using: :btree
    t.index ["feed_id"], name: "index_entries_on_feed_id", using: :btree
  end

  create_table "feeds", force: :cascade do |t|
    t.string   "title"
    t.string   "description"
    t.string   "feed_url",                                         null: false
    t.string   "url"
    t.datetime "last_fetch_at"
    t.string   "fetch_status",       default: "not_yet_attempted"
    t.json     "fetch_error_info"
    t.string   "http_etag"
    t.string   "http_last_modified"
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.index ["feed_url"], name: "index_feeds_on_feed_url", unique: true, using: :btree
  end

end
