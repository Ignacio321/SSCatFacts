# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "cat_lover_#{n}" }
    password { 'supersecret123' }
  end
end
