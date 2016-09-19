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

ActiveRecord::Schema.define(version: 20160918211209) do

  create_table "bucket_blocks", force: :cascade do |t|
    t.integer  "block_number",            null: false
    t.string   "previous",                null: false
    t.datetime "timestamp",               null: false
    t.string   "transaction_merkle_root", null: false
    t.string   "witness",                 null: false
    t.string   "witness_signature",       null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["block_number"], name: "index_bucket_blocks_on_block_number", unique: true
  end

  create_table "bucket_operations", force: :cascade do |t|
    t.string   "type",           null: false
    t.integer  "transaction_id", null: false
    t.string   "payload",        null: false
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["transaction_id"], name: "index_bucket_operations_on_transaction_id"
    t.index ["type"], name: "index_bucket_operations_on_type"
  end

  create_table "bucket_transactions", force: :cascade do |t|
    t.integer  "block_id",                   null: false
    t.integer  "ref_block_num",              null: false
    t.integer  "ref_block_prefix", limit: 8, null: false
    t.datetime "expiration",                 null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["block_id"], name: "index_bucket_transactions_on_block_id"
  end

end
