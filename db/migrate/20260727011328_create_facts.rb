# frozen_string_literal: true

class CreateFacts < ActiveRecord::Migration[8.1]
  def change
    create_table :facts do |t|
      t.text :text, null: false
      t.integer :length, null: false

      t.timestamps
    end
    add_index :facts, :text, unique: true
  end
end
