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

ActiveRecord::Schema.define(version: 20161105184107) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chat_members", force: :cascade do |t|
    t.integer "user_id"
    t.integer "chat_id"
    t.integer "roles_mask"
  end

  add_index "chat_members", ["chat_id"], name: "index_chat_members_on_chat_id", using: :btree
  add_index "chat_members", ["user_id"], name: "index_chat_members_on_user_id", using: :btree

  create_table "chats", force: :cascade do |t|
    t.string "title"
    t.string "type"
  end

  create_table "contact_relations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "contact_id"
  end

  add_index "contact_relations", ["contact_id"], name: "index_contact_relations_on_contact_id", using: :btree
  add_index "contact_relations", ["user_id", "contact_id"], name: "index_contact_relations_on_user_id_and_contact_id", using: :btree
  add_index "contact_relations", ["user_id"], name: "index_contact_relations_on_user_id", using: :btree

  create_table "group_chats", id: false, force: :cascade do |t|
    t.integer "id",                default: "nextval('chats_id_seq'::regclass)", null: false
    t.string  "title"
    t.string  "type"
    t.boolean "everyone_is_admin"
  end

  add_index "group_chats", ["id"], name: "index_group_chats_on_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "chat_id"
    t.text     "text"
    t.datetime "created_at"
  end

  add_index "messages", ["chat_id"], name: "index_messages_on_chat_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "private_chats", id: false, force: :cascade do |t|
    t.integer "id",    default: "nextval('chats_id_seq'::regclass)", null: false
    t.string  "title"
    t.string  "type"
  end

  add_index "private_chats", ["id"], name: "index_private_chats_on_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "name"
    t.string   "nickname"
    t.string   "image"
    t.string   "email"
    t.json     "tokens"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree

end
