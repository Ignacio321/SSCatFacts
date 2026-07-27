# frozen_string_literal: true

class CreateLikes < ActiveRecord::Migration[8.1]
  def change
    create_table :likes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :fact, null: false, foreign_key: true

      t.timestamps
    end
    add_index :likes, %i[user_id fact_id], unique: true
  end
end
