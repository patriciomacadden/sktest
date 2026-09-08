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

ActiveRecord::Schema[8.1].define(version: 2026_09_08_152504) do
  create_table "comment_deletions", force: :cascade do |t|
    t.integer "comment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_comment_deletions_on_comment_id", unique: true
  end

  create_table "comment_votes", force: :cascade do |t|
    t.integer "comment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["comment_id"], name: "index_comment_votes_on_comment_id"
    t.index ["user_id", "comment_id"], name: "index_comment_votes_on_user_id_and_comment_id", unique: true
  end

  create_table "comments", force: :cascade do |t|
    t.integer "author_id"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.bigint "parent_id"
    t.integer "post_id", null: false
    t.datetime "updated_at", null: false
    t.integer "votes_count", default: 0, null: false
    t.index ["author_id"], name: "index_comments_on_author_id"
    t.index ["post_id", "id"], name: "index_comments_on_post_id_and_id", unique: true
    t.index ["post_id", "parent_id", "created_at", "id"], name: "index_comments_on_thread_order"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.check_constraint "parent_id IS NULL OR parent_id != id", name: "comments_not_own_parent"
  end

  create_table "posts", force: :cascade do |t|
    t.integer "author_id", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.integer "votes_count", default: 0, null: false
    t.index ["author_id", "created_at"], name: "index_posts_on_author_id_and_created_at"
    t.index ["author_id"], name: "index_posts_on_author_id"
    t.index ["created_at"], name: "index_posts_on_created_at"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "post_id", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["post_id"], name: "index_votes_on_post_id"
    t.index ["user_id", "post_id"], name: "index_votes_on_user_id_and_post_id", unique: true
  end

  add_foreign_key "comment_deletions", "comments", on_delete: :cascade
  add_foreign_key "comment_votes", "comments", on_delete: :cascade
  add_foreign_key "comment_votes", "users"
  add_foreign_key "comments", "comments", column: ["post_id", "parent_id"], primary_key: ["post_id", "id"]
  add_foreign_key "comments", "posts", on_delete: :cascade
  add_foreign_key "comments", "users", column: "author_id", on_delete: :nullify
  add_foreign_key "posts", "users", column: "author_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "votes", "posts"
  add_foreign_key "votes", "users"
end
