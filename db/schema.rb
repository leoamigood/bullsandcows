# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20161012131330) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dictionaries", force: :cascade do |t|
    t.string   "source",     limit: 64
    t.string   "lang",       limit: 2
    t.boolean  "enabled",               default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "games", force: :cascade do |t|
    t.string   "secret",        limit: 64
    t.integer  "status",                   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "channel"
    t.string   "source"
    t.integer  "hints",                    default: 0
    t.integer  "dictionary_id"
    t.integer  "level"
  end

  create_table "guesses", force: :cascade do |t|
    t.integer  "game_id"
    t.string   "word"
    t.integer  "bulls"
    t.integer  "cows"
    t.integer  "attempts",   default: 0
    t.boolean  "exact"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username"
  end

  create_table "nouns", force: :cascade do |t|
    t.string  "noun",          limit: 64
    t.integer "dictionary_id"
    t.boolean "excluded",                 default: false, null: false
    t.integer "level"
    t.float   "ipm"
    t.integer "r"
    t.integer "d"
    t.integer "doc"
  end

  create_table "settings", force: :cascade do |t|
    t.string   "channel"
    t.string   "language",      default: "RU"
    t.string   "complexity",    default: "easy"
    t.integer  "dictionary_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
