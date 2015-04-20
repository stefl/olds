module StoriesHelper

  def twitter_meta_for_story story
    twitter_meta = {
      description: "On this day in #{story.year}",
      title: story.clickbait,
      site: "@yesterio",
      url: "http://yester.io/stories/#{story.friendly_id}"
    }
    if story.image.present?
      twitter_meta[:image] = story.image
      twitter_meta[:card] = 'summary_large_image'
    else
      twitter_meta[:card] = 'summary'
    end
    twitter_meta
  end
  
  def facebook_meta_for_story story
    fb_meta = {
      type: "article",
      url: "http://yester.io/stories/#{story.friendly_id}",
      title: story.clickbait,
      description: "On this day in #{story.year}"
    }
    if story.image.present?
      fb_meta[:image] = story.image
    end
    fb_meta
  end
end
