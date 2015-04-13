class StoriesController < ApplicationController



  def show
    @story = Story.friendly.find(params[:id])
    @title = @story.clickbait
    next_prev
    doc = Nokogiri::HTML(@story.body).css("#mw-content-text")
    doc.css(".hatnote").first.remove rescue nil
    doc.css(".mw-editsection, .toc, .infobox, .navbox, .metadata, .noprint, table.vertical-navbox, table.mbox-small").each {|d| d.remove }
    if(@story.image.present?)
      img_file_name = @story.image.split("/").last.sub(/^[0-9]+px/,"")
      Rails.logger.info img_file_name
      doc.css(".thumb").each do |thumb|
        doc.css("img").each do |img|
          img_candidate_file_name = img.attr("src").split("/").last.sub(/^[0-9]+px/,"")
          Rails.logger.info img_candidate_file_name
          if img_candidate_file_name == img_file_name
            thumb.remove
          end
        end
      end
    end
    parent = doc.css("#See_also, #References, #Notes").first.parent
    parent_index = parent.parent.children.index(parent)
    total_children = parent.parent.children.count
    parent.add_previous_sibling(Nokogiri.make("<details id=\"reference_details\"><summary>Further reading</summary></details>"))
    details = doc.css("#reference_details").first
    while e = details.next_element
      details.add_child(e)
    end
    @story_body = doc.to_s.gsub("/wiki/", "http://en.wikipedia.org/wiki/")
  end

  def yesterday
    date = Date.today - 1.day
    stories_for_day date
    render :"visitors/index"
  end

  def tomorrow
    date = Date.today + 1.day
    stories_for_day date
    render :"visitors/index"
  end
end
