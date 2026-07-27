# frozen_string_literal: true

class Fact < ApplicationRecord
  has_many :likes, dependent: :destroy
  has_many :users, through: :likes

  validates :text, presence: true, uniqueness: true
  validates :length, presence: true
end
