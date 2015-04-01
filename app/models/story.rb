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
    self.image = self.thumbnail
  end

  def clickbait
    regex = ["the","a","an","was","are","were"].collect { |i|"\\b#{i}\\b" }.join("|")
    bait = self.headline.split(":").last.gsub(/#{regex}/i, "").gsub(" (pictured)","").sub(/\.$/,"")
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
    json = JSON.parse(HTTP.get("http://dbpedia.org/data/#{self.slug}.json").to_s)
    self.dbpedia = json
  end

  def guess_subject
    searches = [
      ["ontology/isPartOfMilitaryConflict", "Conflict"],
      ["resource/Category:Music", "Music"],
      ["dbpedia.org/property/parliament", "Politics"],
      ["property/discovery", "Science"]
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
    if src = Nokogiri::HTML(self.body).css(".infobox img").first.attr("src").sub(/\d+px/,"640px") rescue nil
      src = src.sub(/^\/\//,"http://")
      r = HTTP.head(src)
      return src if r.code == 200
    end
  end

  def self.fetch_for_day the_day, the_month
    source = HTTP.get("http://en.wikipedia.org/wiki/Wikipedia:Selected_anniversaries/#{Date::MONTHNAMES[the_month]}_#{the_day}").to_s
    doc = Nokogiri::HTML(source)
    articles = doc.css("#mw-content-text").css("ul").last.css("li")
    articles.each do |article|
      wp_url = CGI.unescape(article.css("b a").attr("href").value)
      next if Story.where(:wikipedia_url => wp_url).exists?
      headline = article.text.sub(/\d+ – /,"")
      subject = headline.scan(/^(.+)\: /).flatten[0]
      headline = headline.sub(/^.+\: /,"")
      story = Story.create({
        :wikipedia_url => wp_url, 
        :headline => headline, 
        :subject => subject,
        :year => article.css("a").first.text.to_i,
        :month => the_month,
        :day => the_day
      })
    end
  end
end
