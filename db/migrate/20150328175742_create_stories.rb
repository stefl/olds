class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.string :slug
      t.text :headline
      t.date :day
      t.integer :year
      t.boolean :feature
      t.text :image
      t.text :body

      t.timestamps null: false
    end
  end
end
