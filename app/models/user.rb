class User < ActiveRecord::Base
  has_secure_password
  has_many :sounds, dependent: :destroy
  has_many :authorizations
  has_many :authorized_sounds, through: :authorizations, source: :sound
  before_save { self.email = email.downcase }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 }, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }

  def full_name
    "#{first_name} #{last_name}"
  end

  def sound_feed
    authorized_ids = "SELECT sound_id FROM authorizations WHERE user_id = :user_id"
    Sound.where("id IN (#{authorized_ids}) OR user_id = :user_id OR public = true", user_id: id).order(created_at: :desc)
  end
end
