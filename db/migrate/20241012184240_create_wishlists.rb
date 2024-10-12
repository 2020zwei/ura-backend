class CreateWishlists < ActiveRecord::Migration[7.1]
  def change
    create_table :wishlists do |t|

      t.references "user", foreign_key: true
      t.string  "title"
      t.text  "description"

      t.timestamps
    end
  end
end
