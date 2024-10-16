# frozen_string_literal: true

class User < ActiveRecord::Base
  # devise configuration
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  has_one_attached :profile_image
  
  # Relations
  has_one :wishlist, dependent: :destroy
  
  # Validations
  validates :first_name, presence: true
  validate :password_complexity

  # callbacks
  after_create :add_to_sendinblue

  def password_token_valid?
    (self.reset_password_sent_at + 30.minutes) > Time.now.utc
  end

  def reset_password!(password)
    self.reset_password_token = nil
    self.password = password
    save!
  end
  
  def avatar_url
    if profile_image.attached?
      IMAGE_URL + "#{profile_image_key}"
    else
      ""
    end
  end

  private
  
  def password_complexity
    return if password.blank?
    
    unless password.match(/[!@#$%^&*(),.?":{}|<>]/)
      errors.add :password, 'must include at least one special character'
    end
  end

  def add_to_sendinblue
    SendinblueContactService.new(self).create_contact
  end

  def profile_image_key
    profile_image.key
  end
end
