# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_token :email_confirmation_token
  has_secure_token :password_reset_token, find_by_digest: 'sha256'
end
