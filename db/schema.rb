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

ActiveRecord::Schema.define(version: 20170302155628) do

  create_table "gem_infos", force: :cascade do |t|
    t.string   "name",              null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "homepage_url"
    t.string   "source_code_url"
    t.string   "documentation_url"
  end

  create_table "gem_usages", force: :cascade do |t|
    t.integer  "gem_version_id",                 null: false
    t.integer  "resource_id",                    null: false
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.boolean  "in_gemfile",     default: false, null: false
    t.index ["gem_version_id"], name: "index_gem_usages_on_gem_version_id"
    t.index ["resource_id"], name: "index_gem_usages_on_resource_id"
  end

  create_table "gem_versions", force: :cascade do |t|
    t.integer  "gem_info_id", null: false
    t.string   "version",     null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["gem_info_id"], name: "index_gem_versions_on_gem_info_id"
  end

  create_table "resources", force: :cascade do |t|
    t.string   "name",            null: false
    t.string   "path",            null: false
    t.string   "resource_type",   null: false
    t.datetime "fetched_at"
    t.string   "status",          null: false
    t.string   "build_image_url"
    t.string   "build_url"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",               default: "", null: false
    t.string   "encrypted_password",  default: "", null: false
    t.string   "provider"
    t.string   "uid"
    t.string   "firstname"
    t.string   "lastname"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
