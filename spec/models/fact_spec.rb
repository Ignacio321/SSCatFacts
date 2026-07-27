# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Fact, type: :model do
  subject { build(:fact) }

  it { is_expected.to validate_presence_of(:text) }
  it { is_expected.to validate_uniqueness_of(:text) }
  it { is_expected.to validate_presence_of(:length) }
  it { is_expected.to have_many(:likes) }
  it { is_expected.to have_many(:users).through(:likes) }
end
