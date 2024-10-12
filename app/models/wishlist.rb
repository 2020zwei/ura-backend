class Wishlist < ApplicationRecord

    # Relations
    belongs_to :user
    has_many :wishlist_products, dependent: :destroy
    has_many :products, through: :wishlist_products
    has_many :shared_wishlists, dependent: :destroy
  
    validates :title, presence: true
end
