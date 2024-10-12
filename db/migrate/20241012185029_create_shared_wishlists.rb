class CreateSharedWishlists < ActiveRecord::Migration[7.1]
  def change
    create_table :shared_wishlists do |t|

      t.references :wishlist, null: false, foreign_key: true
      t.string :shareable_link, null: true, index: { unique: true }
      t.string :email
      t.datetime :shared_at
      
      t.timestamps
    end
  end
end
