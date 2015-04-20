class CreateSnippets < ActiveRecord::Migration
  def change
    create_table :snippets do |t|
      t.integer :story_id
      t.json :image

      t.timestamps null: false
    end
  end
end
