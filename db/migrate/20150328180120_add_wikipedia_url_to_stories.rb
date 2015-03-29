class AddWikipediaUrlToStories < ActiveRecord::Migration
  def change
    add_column :stories, :wikipedia_url, :string
  end
end
