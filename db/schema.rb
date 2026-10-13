# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_13_172517) do
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
    t.string "checksum"
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "conferences", force: :cascade do |t|
    t.string "name"
    t.string "contact_name"
    t.string "contact_email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "facebook_account"
    t.string "twitter_account"
    t.string "youtube_account"
    t.string "domain"
    t.string "slogan"
    t.boolean "main", default: false, null: false
    t.text "about"
    t.string "theme", default: "default", null: false
    t.string "instagram_account"
    t.string "copyright"
    t.text "analytics_code"
    t.string "code_of_conduct_url"
    t.text "subscribe_code"
    t.index ["domain"], name: "index_conferences_on_domain"
    t.index ["main"], name: "index_conferences_on_main"
  end

  create_table "events", force: :cascade do |t|
    t.integer "conference_id"
    t.string "name", null: false
    t.date "date", null: false
    t.boolean "publicly_announced", default: false, null: false
    t.string "event_url"
    t.string "venue_name"
    t.string "venue_site_url"
    t.string "venue_address"
    t.string "venue_map_url"
    t.text "venue_notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "after_party_venue_name"
    t.string "after_party_venue_site_url"
    t.string "after_party_venue_address"
    t.string "after_party_venue_notes"
    t.text "after_party_venue_map_url"
    t.string "town"
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
    t.string "color"
    t.string "call_to_papers_url"
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

  create_table "feedbacks", force: :cascade do |t|
    t.integer "event_id", null: false
    t.text "comment", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "photos", force: :cascade do |t|
    t.integer "event_id", null: false
    t.integer "position", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "session_speakers", force: :cascade do |t|
    t.integer "speaker_id", null: false
    t.integer "session_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["speaker_id", "session_id"], name: "index_session_speakers_on_speaker_id_and_session_id", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "event_id", null: false
    t.string "start_at", null: false
    t.string "title", null: false
    t.string "slides_url"
    t.string "video_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "track", default: 1, null: false
    t.string "end_at"
    t.text "description"
  end

  create_table "speakers", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "personal_site"
    t.string "company"
    t.string "company_site"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "twitter_account"
    t.string "tshirt_size"
    t.string "github_account"
    t.string "facebook_account"
    t.string "dribbble_account"
    t.boolean "organizer", default: false, null: false
    t.string "instagram_account"
    t.string "linkedin_account"
  end

  create_table "sponsors", force: :cascade do |t|
    t.string "name", null: false
    t.string "website_url", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", default: "", null: false
    t.string "password_digest", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "events", "conferences"
  add_foreign_key "events_sponsors", "events"
  add_foreign_key "events_sponsors", "sponsors"
  add_foreign_key "feedbacks", "events"
  add_foreign_key "photos", "events"
  add_foreign_key "session_speakers", "sessions"
  add_foreign_key "session_speakers", "speakers"
  add_foreign_key "sessions", "events"
end
