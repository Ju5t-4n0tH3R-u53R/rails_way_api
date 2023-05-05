class User < ActiveRecord::Base
  has_secure_password

  has_many :purchases

  validates :name, :email, :password_digest, presence: true, on: %i[create update]
  validates :auth_token, uniqueness: true

  before_create do |user|
    generate_auth_token(user)
  end

  def generate_auth_token(user)
    user.auth_token = SecureRandom.base64 if User.find_by(auth_token: user.auth_token).nil?
  end
end
