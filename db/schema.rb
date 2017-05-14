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

ActiveRecord::Schema.define(version: 20170513212844) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dictionaries", force: :cascade do |t|
    t.string   "source",     limit: 255
    t.string   "lang",       limit: 2
    t.boolean  "enabled",                default: true
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "dictionary_levels", force: :cascade do |t|
    t.integer "dictionary_id"
    t.string  "complexity"
    t.integer "min_level"
    t.integer "max_level"
    t.string  "lang"
  end

  create_table "games", force: :cascade do |t|
    t.string   "secret",        limit: 64
    t.string   "status",                   default: "created"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "channel"
    t.string   "source"
    t.integer  "hints_count",              default: 0
    t.integer  "dictionary_id"
    t.integer  "level"
    t.integer  "guesses_count",            default: 0
    t.integer  "user_id"
    t.integer  "winner_id"
  end

  create_table "guesses", force: :cascade do |t|
    t.integer  "game_id"
    t.string   "word"
    t.integer  "bulls"
    t.integer  "cows"
    t.integer  "attempts",   default: 0
    t.boolean  "exact"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.string   "username"
    t.boolean  "suggestion", default: false
    t.integer  "user_id"
    t.boolean  "common"
  end

  create_table "hints", force: :cascade do |t|
    t.integer  "game_id"
    t.string   "letter"
    t.string   "hint"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer "rank"
  end

  add_index "nouns", ["noun", "dictionary_id"], name: "index_nouns_on_noun_and_dictionary_id", unique: true, using: :btree

  create_table "scores", force: :cascade do |t|
    t.integer  "game_id"
    t.integer  "channel"
    t.integer  "winner_id"
    t.integer  "worth"
    t.integer  "bonus",      default: 0
    t.integer  "penalty",    default: 0
    t.integer  "points",     default: 0
    t.integer  "total",      default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "settings", force: :cascade do |t|
    t.string   "channel"
    t.string   "language",      default: "RU"
    t.string   "complexity",    default: "easy"
    t.integer  "dictionary_id"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer  "ext_id",     null: false
    t.string   "source",     null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
