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

ActiveRecord::Schema.define(version: 20160610155945) do

  create_table "access_points", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "location_id"
    t.string   "name"
    t.string   "bssid_base"
    t.string   "bssid_top"
    t.string   "building"
    t.string   "room"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fingerprints", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "measurement_id"
    t.integer  "location_id"
    t.datetime "created_at",     null: false
    t.index ["location_id"], name: "index_fingerprints_on_location_id", using: :btree
    t.index ["measurement_id"], name: "index_fingerprints_on_measurement_id", using: :btree
  end

  create_table "locations", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "map_id"
    t.string   "name"
    t.float    "map_x",      limit: 24
    t.float    "map_y",      limit: 24
    t.float    "accuracy",   limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "maps", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "measurements", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "tag"
    t.datetime "created_at", null: false
  end

  create_table "readings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "measurement_id"
    t.string  "ssid"
    t.string  "bssid"
    t.integer "rssi"
    t.integer "channel"
    t.string  "ht"
    t.string  "cc"
    t.string  "security"
    t.boolean "wep_enabled"
    t.boolean "infrastructure_mode"
  end

end
