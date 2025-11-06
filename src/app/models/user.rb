# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password

  has_many :tasks, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: /@/
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
end
