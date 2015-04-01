class StoriesController < ApplicationController

  def show
    @story = Story.friendly.find(params[:id])
    @title = @story.clickbait
    
    doc = Nokogiri::HTML(@story.body).css("#mw-content-text")
    doc.css(".hatnote").first.remove rescue nil
    doc.css(".mw-editsection, .toc, .infobox, .navbox, .metadata, .noprint, table.vertical-navbox, table.mbox-small").each {|d| d.remove }
    @story_body = doc.to_s.gsub("/wiki/", "http://en.wikipedia.org/wiki/")
  end
end
