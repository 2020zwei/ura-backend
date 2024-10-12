class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|

      t.string :amazon_id, null: false, index: true
      t.string :name
      t.text :description
      t.string :image_url
      t.decimal :price, precision: 10, scale: 2
      t.string :affiliate_link

      t.timestamps
    end
  end
end
