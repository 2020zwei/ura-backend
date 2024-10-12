class Product < ApplicationRecord

    # Relations
    has_many :wishlist_products
    has_many :wishlists, through: :wishlist_products
  
    validates :amazon_id, presence: true, uniqueness: true
    validates :name, presence: true
    validates :affiliate_link, presence: true

end
