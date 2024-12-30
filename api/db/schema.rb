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

ActiveRecord::Schema[8.0].define(version: 2024_12_28_215651) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "players", force: :cascade do |t|
    t.string "name"
    t.integer "chips", default: 1000
    t.string "cards", default: [], array: true
    t.bigint "room_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: true
    t.index ["room_id"], name: "index_players_on_room_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.string "phase"
    t.integer "max_players"
    t.string "community_cards", default: [], array: true
    t.integer "pot", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "current_turn", default: 1
    t.integer "current_bet", default: 0
  end

  add_foreign_key "players", "rooms"
end
