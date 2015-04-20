class AddTextToSnippets < ActiveRecord::Migration
  def change
    add_column :snippets, :text, :text
  end
end
