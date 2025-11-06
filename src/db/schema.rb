# frozen_string_literal: true

ActiveRecord::Schema[7.1].define(version: 20250101000100) do
  create_table "tasks", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.datetime "due_at"
    t.integer "priority", default: 1, null: false
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["due_at"], name: "index_tasks_on_due_at"
    t.index ["user_id", "completed"], name: "index_tasks_on_user_id_and_completed"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "tasks", "users"
end
