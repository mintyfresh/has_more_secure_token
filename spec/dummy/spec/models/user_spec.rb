# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  subject(:user) { described_class.new }

  it 'is valid' do
    expect(user).to be_valid
  end

  describe '.find_by_password_reset_token' do
    let(:user) { described_class.create! }

    it 'returns the user when the token is correct' do
      expect(described_class.find_by_password_reset_token(user.password_reset_token)).to eq(user)
    end

    it 'returns nil when the token is incorrect' do
      expect(described_class.find_by_password_reset_token('a' * HasMoreSecureToken::MINIMUM_TOKEN_LENGTH)).to be_nil
    end

    it 'returns nil when the token is blank' do
      expect(described_class.find_by_password_reset_token('')).to be_nil
    end

    it 'returns nil when the token is nil' do
      expect(described_class.find_by_password_reset_token(nil)).to be_nil
    end

    it 'returns nil when the token is a different token' do
      expect(described_class.find_by_password_reset_token(user.email_confirmation_token)).to be_nil
    end
  end
end
