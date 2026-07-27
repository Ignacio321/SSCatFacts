# frozen_string_literal: true

FactoryBot.define do
  factory :fact do
    sequence(:text) { |n| "Cats fact number #{n}." }
    length { text.length }
  end
end
