class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :posts, foreign_key: :author_id, dependent: :destroy
  has_many :votes, dependent: :delete_all

  normalizes :email_address, with: ->(email_address) { email_address.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
