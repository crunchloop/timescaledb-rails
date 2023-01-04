# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 6) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "timescaledb"

  create_table "event_types", force: :cascade do |t|
    t.integer "type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "events", id: false, force: :cascade do |t|
    t.string "name", null: false
    t.time "occurred_at", null: false
    t.time "recorded_at", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "event_type_id"
    t.index ["created_at", "name"], name: "index_events_on_created_at_and_name"
    t.index ["created_at"], name: "events_created_at_idx", order: :desc
    t.index ["event_type_id"], name: "index_events_on_event_type_id"
  end

  create_hypertable "events", "created_at", chunk_time_interval: "2 days"

  add_hypertable_compression "events", "20 days", segment_by: "event_type_id, name", order_by: "occurred_at ASC, recorded_at DESC"

  add_hypertable_reorder_policy "events", "index_events_on_created_at_and_name"

  add_hypertable_retention_policy "events", "1 year"

  create_table "payloads", id: false, force: :cascade do |t|
    t.integer "id", default: -> { "nextval('payload_id_seq'::regclass)" }, null: false
    t.string "data", null: false
    t.string "format", null: false
    t.string "ip", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["created_at"], name: "payloads_created_at_idx", order: :desc
    t.index ["id", "created_at"], name: "index_payloads_on_id_and_created_at"
  end

  create_hypertable "payloads", "created_at", chunk_time_interval: "5 days"

end
