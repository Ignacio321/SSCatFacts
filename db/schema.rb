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

ActiveRecord::Schema[8.1].define(version: 2026_07_27_011348) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "facts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "length", null: false
    t.text "text", null: false
    t.datetime "updated_at", null: false
    t.index ["text"], name: "index_facts_on_text", unique: true
  end

  create_table "likes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "fact_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["fact_id"], name: "index_likes_on_fact_id"
    t.index ["user_id", "fact_id"], name: "index_likes_on_user_id_and_fact_id", unique: true
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "likes", "facts"
  add_foreign_key "likes", "users"
end
