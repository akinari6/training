# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.datetime :due_at
      t.integer :priority, null: false, default: 1
      t.boolean :completed, null: false, default: false

      t.timestamps
    end

    add_index :tasks, %i[user_id completed]
    add_index :tasks, :due_at
  end
end
