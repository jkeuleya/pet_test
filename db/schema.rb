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

ActiveRecord::Schema[7.2].define(version: 2025_07_10_130940) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "pets", force: :cascade do |t|
    t.string "name", null: false
    t.string "breed", null: false
    t.integer "age", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["breed"], name: "index_pets_on_breed"
    t.index ["name"], name: "index_pets_on_name"
  end

  create_table "vaccination_records", force: :cascade do |t|
    t.bigint "pet_id", null: false
    t.string "name", null: false
    t.date "vaccination_date", null: false
    t.date "expiry_date", null: false
    t.boolean "expired", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expired"], name: "index_vaccination_records_on_expired"
    t.index ["expiry_date"], name: "index_vaccination_records_on_expiry_date"
    t.index ["pet_id", "expired"], name: "index_vaccination_records_on_pet_id_and_expired"
    t.index ["pet_id"], name: "index_vaccination_records_on_pet_id"
  end

  add_foreign_key "vaccination_records", "pets"
end
