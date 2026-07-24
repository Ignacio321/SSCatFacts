# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  validates :username, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }, allow_nil: true
end
