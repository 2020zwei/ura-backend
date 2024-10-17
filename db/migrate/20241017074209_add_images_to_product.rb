class AddImagesToProduct < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :images, :jsonb, default: []
    add_column :products, :thumbnails, :jsonb, default: []
  end
end
