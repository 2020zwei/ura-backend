class AddRatingToProduct < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :rating, :float, default: 0
  end
end
