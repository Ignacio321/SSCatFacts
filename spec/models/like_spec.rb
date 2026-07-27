# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Like, type: :model do
  subject { create(:like) }

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:fact) }
  it { is_expected.to validate_uniqueness_of(:fact_id).scoped_to(:user_id) }
end
