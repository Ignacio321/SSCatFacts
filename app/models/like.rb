# frozen_string_literal: true

class Like < ApplicationRecord
  belongs_to :user
  belongs_to :fact

  validates :fact_id, uniqueness: { scope: :user_id }
end
