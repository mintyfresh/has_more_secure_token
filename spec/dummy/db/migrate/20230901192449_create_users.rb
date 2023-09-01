# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto'

    create_table :users do |t|
      t.binary :email_confirmation_token
      t.binary :password_reset_token

      t.timestamps
    end
  end
end
