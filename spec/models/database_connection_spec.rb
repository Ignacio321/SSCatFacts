# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Database connection' do
  it 'connects to the test database' do
    expect(ActiveRecord::Base.connection.active?).to be(true)
  end
end
