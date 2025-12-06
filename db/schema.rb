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

ActiveRecord::Schema[7.2].define(version: 2025_12_06_071509) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "stock_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id"], name: "index_bookmarks_on_stock_id"
    t.index ["user_id", "stock_id"], name: "index_bookmarks_on_user_id_and_stock_id", unique: true
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "comment_likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "comment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_comment_likes_on_comment_id"
    t.index ["user_id", "comment_id"], name: "index_comment_likes_on_user_id_and_comment_id", unique: true
    t.index ["user_id"], name: "index_comment_likes_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "post_id", null: false
    t.text "body"
    t.integer "likes_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id", "created_at"], name: "index_comments_on_post_id_and_created_at"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "post_likes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_post_likes_on_post_id"
    t.index ["user_id", "post_id"], name: "index_post_likes_on_user_id_and_post_id", unique: true
    t.index ["user_id"], name: "index_post_likes_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "stock_id", null: false
    t.text "body"
    t.text "image_url"
    t.integer "likes_count", default: 0, null: false
    t.integer "comments_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id", "created_at"], name: "index_posts_on_stock_id_and_created_at"
    t.index ["stock_id"], name: "index_posts_on_stock_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "price_candles", force: :cascade do |t|
    t.bigint "stock_id", null: false
    t.datetime "time", null: false
    t.string "interval", limit: 20, null: false
    t.decimal "open", precision: 15, scale: 4
    t.decimal "high", precision: 15, scale: 4
    t.decimal "low", precision: 15, scale: 4
    t.decimal "close", precision: 15, scale: 4
    t.bigint "volume"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stock_id", "interval", "time"], name: "index_price_candles_on_stock_id_and_interval_and_time", unique: true
    t.index ["stock_id"], name: "index_price_candles_on_stock_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "symbol", limit: 30, null: false
    t.string "name", limit: 250
    t.string "name_kr", limit: 250
    t.string "market", limit: 250
    t.string "sector", limit: 250
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["symbol"], name: "index_stocks_on_symbol", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name"
    t.string "avatar_url", limit: 300
    t.string "role", limit: 30
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "bookmarks", "stocks"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "comment_likes", "comments"
  add_foreign_key "comment_likes", "users"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "post_likes", "posts"
  add_foreign_key "post_likes", "users"
  add_foreign_key "posts", "stocks"
  add_foreign_key "posts", "users"
  add_foreign_key "price_candles", "stocks"
end
