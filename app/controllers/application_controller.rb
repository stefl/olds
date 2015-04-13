class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def next_prev
    @headlines = Story.where(["day = ? and month = ? and image is not null and feature = true",Date.today.day, Date.today.month])
    @sublines = Story.where(["day = ? and month = ? and image is not null and feature = false",Date.today.day, Date.today.month])
    @other_news = Story.where(["day = ? and month = ? and image is null",Date.today.day, Date.today.month])
    @story_slugs = @headlines.collect(&:friendly_id) + @sublines.collect(&:friendly_id) + @other_news.collect(&:friendly_id)
    
    if(@story)
      current_story_position = @story_slugs.index(@story.friendly_id)
      @next_story_slug = @story_slugs[current_story_position + 1] rescue @story_slugs.first
      @prev_story_slug = @story_slugs[current_story_position -1 ] rescue @story_slugs.last
    else
      @next_story_slug = @story_slugs.first
      @prev_story_slug = @story_slugs.last
    end
  end
end
