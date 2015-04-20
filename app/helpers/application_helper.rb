module ApplicationHelper

  def standard_metadata
    {
      site: "Yester",
      title: [:title, :site], 
      separator: " — ",
      description: "Learn about the world by reading about what happened on this day in history"
    }
  end
  
end
