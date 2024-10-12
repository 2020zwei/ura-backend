class SharedWishlist < ApplicationRecord

    # Relations
    belongs_to :wishlist

    validates :shareable_link, presence: true, uniqueness: true
    
end
