class AddMonthToStories < ActiveRecord::Migration
  def change
    remove_column :stories, :day
    add_column :stories, :day, :integer
    add_column :stories, :month, :integer
  end
end
