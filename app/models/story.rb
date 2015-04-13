require "open-uri"

class Story < ActiveRecord::Base
  extend FriendlyId
  friendly_id :slug

  before_save :fetch_from_wikipedia
  before_save :fetch_dbpedia

  def set_slug_from_wikipedia_url
    self.slug = self.wikipedia_url.to_s.split("/").last if self.slug.blank?
  end

  def fetch_from_wikipedia
    return if self.body.present?
    self.set_slug_from_wikipedia_url
    self.body = HTTP.get(URI.encode("http://en.wikipedia.org#{self.wikipedia_url}")).to_s
    self.fetch_thumbnail
  end

  def fetch_thumbnail
    image_details = self.thumbnail
    self.image = image_details[:src] rescue nil
    self.image_width = image_details[:width] rescue nil
    self.image_height = image_details[:height] rescue nil
  end

  def clickbait
    regex = ["the","a","an","was","are","were"].collect { |i|"\\b#{i}\\b" }.join("|")
    bait = self.headline.split(":").last.gsub(/#{regex}/i, "").gsub(" (pictured)","").sub(/\.$/,"")
    bait.sub!(/^[0-9]+ \- /,"")
    2.times do
      old_bait = bait
      if bait.scan(/\S+/).count > 11
        arr = bait.split(", ")
        arr.pop
        bait = arr.join(", ")
      end
      if bait.blank? || bait.scan(/\S+/).count < 8
        bait = old_bait
      end
    end
    bait = bait.squish
    bait[0] = bait[0].capitalize
    bait

  end

  def fetch_dbpedia
    return if self.dbpedia.present?
    self.set_slug_from_wikipedia_url
    json = JSON.parse(HTTP.get(URI.encode("http://dbpedia.org/data/#{self.slug}.json").to_s))
    self.dbpedia = json
  end

  def guess_subject
    searches = [
      ["ontology/isPartOfMilitaryConflict", "Conflict"],
      ["http://dbpedia.org/ontology/battle", "Conflict"],
      ["resource/Category:Music", "Music"],
      ["dbpedia.org/property/parliament", "Politics"],
      ["property/discovery", "Science"],
      ["http://dbpedia.org/ontology/location", "World"],
      ["software", "Technology"],
      ["http://dbpedia.org/property/dateOfDeath", "People"],
      ["http://dbpedia.org/ontology/Royalty","Royalty"],
      ["dbpedia.org/resource/Category:Natural_disasters", "Disasters"],
      ["http://dbpedia.org/property/birthDate", "People"],
      ["http://dbpedia.org/class/yago/Demographic", "Economics"],
      ["http://dbpedia.org/class/yago/Treaties","World"],
      ["http://dbpedia.org/property/weapons", "Conflict"],
      ["http://dbpedia.org/class/yago/Act","Politics"],
      ["http://dbpedia.org/resource/Category:Medical_research","Science"]
    ]
    json_s = self.dbpedia.to_s
    searches.each do |search|
      if json_s.include? search[0]
        return search[1]
      end
    end
    nil
  end

  def thumbnail
    doc = Nokogiri::HTML(self.body)
    doc.css(".flagicon").each {|e| e.remove }
    img = doc.css(".infobox img").first rescue nil
    img ||= doc.css(".thumb img").first rescue nil
    
    if img
      return unless img.attr("data-file-width").to_i > 640
      src = img.attr("src").sub(/\d+px/,"640px").sub(/^\/\//,"http://")
      r = HTTP.head(src)
      if r.code == 200
        result = {
          :src => src, 
          :width => img.attr("data-file-width"), 
          :height => img.attr("data-file-height")
        } 
      end
    end
  end

  def self.from_wikipedia_url wp_url, the_year, the_month, the_day, headline, to_feature
    return if Story.where(:wikipedia_url => wp_url).exists?
    subject = headline.scan(/^(.+)\: /).flatten[0]
    headline = headline.sub(/^.+\: /,"")
    story = Story.create({
      :wikipedia_url => wp_url, 
      :headline => headline, 
      :subject => subject,
      :year => the_year,
      :month => the_month,
      :day => the_day,
      :feature => to_feature
    })
  end

  def self.from_wikipedia_doc_fragment article, month, day, to_feature
    Rails.logger.info article
    wp_url = CGI.unescape(article.css("b a").attr("href").value)
    Rails.logger.info wp_url
    headline = article.text.sub(/\d+ – /,"") 
    year = article.css("a").first.text.to_i
    Story.from_wikipedia_url wp_url, year, month, day, headline, to_feature
  end

  def self.fetch_for_day the_day, the_month
    source = HTTP.get("http://en.wikipedia.org/wiki/Wikipedia:Selected_anniversaries/#{Date::MONTHNAMES[the_month]}_#{the_day}").to_s
    doc = Nokogiri::HTML(source)
    articles = doc.css("#mw-content-text").css("ul").last.css("li")
    articles.each do |article|
      Story.from_wikipedia_doc_fragment article, the_month, the_day, true
    end

    other_articles = doc.css(".collapsed > div.NavContent > ul:not(.gallery)").first.css("li")
    other_articles.each do |article|
      Story.from_wikipedia_doc_fragment article, the_month, the_day, false
    end
  end

  def self.today
    headlines = Story.where(["day = ? and month = ? and image is not null and feature = true",Date.today.day, Date.today.month])
    sublines = Story.where(["day = ? and month = ? and image is not null and feature = false",Date.today.day, Date.today.month])
    other_news = Story.where(["day = ? and month = ? and image is null",Date.today.day, Date.today.month])
    headlines + sublines + other_news
  end
end
