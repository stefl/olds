class AddDbpediaToStories < ActiveRecord::Migration
  def change
    add_column :stories, :dbpedia, :json
  end
end
