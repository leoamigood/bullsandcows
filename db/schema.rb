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

ActiveRecord::Schema.define(version: 20160517141946) do

  create_table "games", force: :cascade do |t|
    t.string   "secret",     limit: 64
    t.string   "channel",    limit: 255
    t.string   "source",     limit: 255
    t.integer  "status",     limit: 4,   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "guesses", force: :cascade do |t|
    t.integer  "game_id",    limit: 4
    t.string   "word",       limit: 255
    t.integer  "bulls",      limit: 4
    t.integer  "cows",       limit: 4
    t.integer  "attempts",   limit: 4,   default: 0
    t.boolean  "exact"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
