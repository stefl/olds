class AddDimensionsToStories < ActiveRecord::Migration
  def change
    add_column :stories, :image_width, :integer
    add_column :stories, :image_height, :integer
  end
end
