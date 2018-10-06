class User < ApplicationRecord
  before_save {self.username = username.downcase}
  validates :username,
  presence: true,
  length: {minimum:4,  maximum: 15 }

  has_secure_password
  validates :password, presence: true, length: { minimum: 8 }
end
