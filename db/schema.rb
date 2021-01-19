# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_01_18_104839) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authors_packages", force: :cascade do |t|
    t.integer "person_id"
    t.integer "package_id"
    t.index ["package_id"], name: "index_authors_packages_on_package_id"
  end

  create_table "maintainers_packages", force: :cascade do |t|
    t.integer "person_id"
    t.integer "package_id"
    t.index ["package_id"], name: "index_maintainers_packages_on_package_id"
  end

  create_table "packages", force: :cascade do |t|
    t.string "name"
    t.string "version"
    t.datetime "publication_date"
    t.string "title"
    t.text "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "version"], name: "index_packages_on_name_and_version", unique: true
  end

  create_table "people", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_people_on_name", unique: true
  end

end
