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

ActiveRecord::Schema[8.0].define(version: 2026_08_11_100002) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "business_settings", force: :cascade do |t|
    t.string "business_name"
    t.text "business_address"
    t.string "abn"
    t.string "email"
    t.text "payment_instructions"
    t.decimal "gst_rate", precision: 5, scale: 2, default: "10.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "invoice_budget_summaries", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.bigint "service_budget_id", null: false
    t.string "name", null: false
    t.string "cadence", null: false
    t.date "period_start"
    t.integer "budget_minutes", null: false
    t.integer "used_minutes", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id", "service_budget_id", "period_start"], name: "index_invoice_budget_summaries_on_snapshot", unique: true
    t.index ["invoice_id"], name: "index_invoice_budget_summaries_on_invoice_id"
    t.index ["service_budget_id"], name: "index_invoice_budget_summaries_on_service_budget_id"
  end

  create_table "invoice_lines", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.bigint "time_entry_id", null: false
    t.date "entry_date", null: false
    t.string "description", null: false
    t.integer "duration_minutes", null: false
    t.integer "hourly_rate_cents", null: false
    t.integer "amount_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_lines_on_invoice_id"
    t.index ["time_entry_id"], name: "index_invoice_lines_on_time_entry_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "status", default: "draft", null: false
    t.string "number"
    t.date "period_start"
    t.date "period_end"
    t.date "due_on"
    t.datetime "issued_at"
    t.datetime "paid_at"
    t.string "sender_name"
    t.text "sender_address"
    t.string "sender_abn"
    t.string "sender_email"
    t.text "payment_instructions"
    t.string "client_name"
    t.text "client_address"
    t.decimal "gst_rate", precision: 5, scale: 2, default: "10.0", null: false
    t.integer "subtotal_cents", default: 0, null: false
    t.integer "tax_cents", default: 0, null: false
    t.integer "total_cents", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_invoices_on_number", unique: true
    t.index ["project_id"], name: "index_invoices_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.string "client_name", null: false
    t.text "client_address"
    t.integer "hourly_rate_cents", null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "service_budgets", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "name", null: false
    t.integer "budget_minutes", null: false
    t.string "cadence", default: "project", null: false
    t.boolean "archived", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "archived", "name"], name: "index_service_budgets_on_project_id_and_archived_and_name"
    t.index ["project_id"], name: "index_service_budgets_on_project_id"
  end

  create_table "time_entries", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "description", null: false
    t.datetime "started_at"
    t.datetime "ended_at"
    t.integer "duration_minutes"
    t.integer "hourly_rate_cents", null: false
    t.string "billing_status", default: "uninvoiced", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "service_budget_id"
    t.index ["billing_status"], name: "index_time_entries_on_billing_status"
    t.index ["project_id"], name: "index_time_entries_on_project_id"
    t.index ["service_budget_id"], name: "index_time_entries_on_service_budget_id"
  end

  add_foreign_key "invoice_budget_summaries", "invoices"
  add_foreign_key "invoice_budget_summaries", "service_budgets"
  add_foreign_key "invoice_lines", "invoices"
  add_foreign_key "invoice_lines", "time_entries"
  add_foreign_key "invoices", "projects"
  add_foreign_key "service_budgets", "projects"
  add_foreign_key "time_entries", "projects"
  add_foreign_key "time_entries", "service_budgets"
end
