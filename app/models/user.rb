# frozen_string_literal: true

class User < ActiveRecord::Base
  # devise configuration
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include DeviseTokenAuth::Concerns::User

  has_one_attached :profile_image
  
  # Validations
  validates :username, format: { with: /\A[a-zA-Z][a-zA-Z0-9]*\z/,
                                message: "should start with an alphabet and can contain both alphabets and numbers, but not consist of only numbers" }
  validates :username, format: { without: /\s/, message: "cannot contain spaces" }
  validates :username, length: { minimum: 1, maximum: 10 }
  validates_uniqueness_of :email, :username
  validate :password_complexity

  private
  
  def password_complexity
    return if password.blank?
    
    unless password.match(/[!@#$%^&*(),.?":{}|<>]/)
      errors.add :password, 'must include at least one special character'
    end
  end
end
