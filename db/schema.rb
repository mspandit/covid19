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

ActiveRecord::Schema.define(version: 2020_03_28_154747) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authors", force: :cascade do |t|
    t.string "first"
    t.string "middle"
    t.string "last"
    t.string "suffix"
    t.string "laboratory"
    t.string "institution"
    t.string "addr_line"
    t.string "post_code"
    t.string "settlement"
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "authorships", force: :cascade do |t|
    t.integer "paper_id"
    t.integer "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "body_texts", force: :cascade do |t|
    t.integer "paper_id"
    t.string "section"
    t.integer "sequence"
    t.text "content"
    t.tsvector "search_vector"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "papers", force: :cascade do |t|
    t.string "paper_id"
    t.string "title"
    t.text "abstract"
    t.tsvector "search_vector"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["search_vector"], name: "abstracts_search_idx", using: :gin
    t.index ["search_vector"], name: "body_texts_search_idx", using: :gin
  end

  create_table "questions", force: :cascade do |t|
    t.string "content"
    t.integer "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "regions", force: :cascade do |t|
    t.string "province"
    t.string "country"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reports", force: :cascade do |t|
    t.integer "region_id"
    t.integer "confirmed"
    t.integer "deaths"
    t.integer "recovered"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "us_reports", force: :cascade do |t|
    t.string "county"
    t.string "state"
    t.integer "cases"
    t.integer "deaths"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
