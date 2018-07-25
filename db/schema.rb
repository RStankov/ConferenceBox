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

ActiveRecord::Schema.define(version: 2018_07_24_132135) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "conferences", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "contact_name", limit: 255
    t.string "contact_email", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "facebook_account", limit: 255
    t.string "twitter_account", limit: 255
    t.string "youtube_account", limit: 255
    t.string "domain", limit: 255
    t.string "slogan", limit: 255
    t.boolean "main", default: false, null: false
    t.text "about"
    t.string "theme", default: "default", null: false
    t.string "instagram_account"
    t.string "copyright"
    t.text "analytics_code"
    t.string "code_of_conduct_url"
    t.index ["domain"], name: "index_conferences_on_domain"
    t.index ["main"], name: "index_conferences_on_main"
  end

  create_table "events", id: :serial, force: :cascade do |t|
    t.integer "conference_id"
    t.string "name", limit: 255, null: false
    t.date "date", null: false
    t.boolean "publicly_announced", default: false, null: false
    t.string "event_url", limit: 255
    t.string "venue_name", limit: 255
    t.string "venue_site_url", limit: 255
    t.string "venue_address", limit: 255
    t.string "venue_map_url", limit: 255
    t.text "venue_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "after_party_venue_name", limit: 255
    t.string "after_party_venue_site_url", limit: 255
    t.string "after_party_venue_address", limit: 255
    t.string "after_party_venue_notes", limit: 255
    t.text "after_party_venue_map_url"
    t.string "town", limit: 255
    t.text "notes"
    t.boolean "dates_announced", default: false
    t.boolean "venue_announced", default: false
    t.boolean "after_party_announced", default: false
    t.boolean "sessions_announced", default: false
    t.boolean "speakers_announced", default: false
    t.boolean "current", default: false, null: false
    t.boolean "show_feedback_form", default: false, null: false
    t.boolean "show_photo_gallery", default: false, null: false
    t.text "streaming_code"
    t.boolean "show_streaming", default: false, null: false
    t.boolean "show_coverart", default: false, null: false
    t.string "color", limit: 255
    t.string "call_to_papers_url", limit: 255
    t.text "venue_map_embedded_url"
    t.text "after_party_venue_map_embedded_url"
    t.string "tickets_url"
    t.boolean "sponsors_announced", default: false, null: false
  end

  create_table "events_sponsors", id: false, force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "sponsor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id", "sponsor_id"], name: "index_events_sponsors_on_event_id_and_sponsor_id", unique: true
    t.index ["event_id"], name: "index_events_sponsors_on_event_id"
    t.index ["sponsor_id"], name: "index_events_sponsors_on_sponsor_id"
  end

  create_table "feedbacks", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.text "comment", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "position", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "session_speakers", id: :serial, force: :cascade do |t|
    t.integer "speaker_id", null: false
    t.integer "session_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["speaker_id", "session_id"], name: "index_session_speakers_on_speaker_id_and_session_id", unique: true
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "start_at", limit: 255, null: false
    t.string "title", limit: 255, null: false
    t.string "slides_url", limit: 255
    t.string "video_url", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "track", default: 1, null: false
    t.string "end_at"
    t.text "description"
  end

  create_table "speakers", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.text "description"
    t.string "personal_site", limit: 255
    t.string "company", limit: 255
    t.string "company_site", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "twitter_account", limit: 255
    t.string "tshirt_size", limit: 255
    t.string "github_account", limit: 255
    t.string "facebook_account", limit: 255
    t.string "dribbble_account", limit: 255
    t.boolean "organizer", default: false, null: false
  end

  create_table "sponsors", force: :cascade do |t|
    t.string "name", null: false
    t.string "website_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "first_name", limit: 255, null: false
    t.string "last_name", limit: 255, null: false
    t.string "email", limit: 255, default: "", null: false
    t.string "password_digest", limit: 255, default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "events", "conferences", name: "events_conference_id_fk"
  add_foreign_key "events_sponsors", "events"
  add_foreign_key "events_sponsors", "sponsors"
  add_foreign_key "feedbacks", "events", name: "feedbacks_event_id_fk"
  add_foreign_key "photos", "events", name: "photos_event_id_fk"
  add_foreign_key "session_speakers", "sessions", name: "session_speakers_session_id_fk"
  add_foreign_key "session_speakers", "speakers", name: "session_speakers_speaker_id_fk"
  add_foreign_key "sessions", "events", name: "sessions_event_id_fk"
end
