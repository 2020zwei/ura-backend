class WishlistProduct < ApplicationRecord

    # Relations
    belongs_to :wishlist
    belongs_to :product
  
    # Optional: Customize the variant (e.g., color, size) for each product
    validates :variant, allow_blank: true, length: { maximum: 255 }
end
