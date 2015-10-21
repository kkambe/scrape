#!/usr/bin/ruby
#
require 'dalli'
require 'mechanize'
require 'open-uri'
require_relative 'scrape_detail'

class Scrape

  @@site_map = {
    "telugu" => {
      "ga" => ScrapeDetail.new("http://www.greatandhra.com/reviews.php", "div.movies_page_news a", "",
                                    "html body div.content p strong span"),
      "ib" => ScrapeDetail.new("http://idlebrain.com/movie/archive/index.html", 
                                    "html body table tr td table tr td table tr td table a", 
                                    "http://idlebrain.com/movie/archive/", 
                                    "html body table tbody tr td p font b font"),
      "gt" => ScrapeDetail.new("http://www.gulte.com/moviereviews", 
                                    "html body div.wrapper div.main div.container ul.list_more li a", "", 
                                    "html body .rating span")                              
    }  
  }

  attr_accessor :dalli_client

  def scrape
    @@site_map.each do |lang, l_map|
      puts "Language: #{lang}"
      l_map.each do |site, s_detail|
        puts "Site: #{site}"
        review_details = fetch_site_data(s_detail.url, s_detail.css_path, s_detail.base_url, s_detail.rating_css_path)
        @dalli_client.set("#{lang}_#{site}", review_details);
      end
    end
  end

  def fetch_site_data(url, css_path, base_url, rating_css_path)
    reviews = []
    # agent = Mechanize.new
    page = Mechanize.new.get(url)
    reviews_count = 0
    page.parser.css(css_path).each do |link|
      break if reviews_count == 5
      reviews_count += 1
      l_map = {}
      l_map['href'] = base_url + link['href']
      l_map['text'] = link.text
      l_map['rating'] = get_rating(l_map['href'], rating_css_path)
      reviews << l_map
    end
    reviews
  end

  def get_rating(url, rating_css_path)
    rating = "N/A"
    begin
      page = Mechanize.new.get(url)
      res = page.parser.css(rating_css_path)[0]
      puts "URL======== " + url.inspect
      puts "CSS PATH======== " + rating_css_path.inspect
      puts "RESULT======== " + res.inspect
      rating = res.text
    rescue Exception => e
      puts "Exception while retrieving rating::: " + e.backtrace.inspect        
    end
    rating
  end

  # TODO: For each language and for each website 
  #       1) fetch the ratings of latest 5 movies 
  #       2) save them in memcached.
  #
  def initialize
    options = {:namespace => 'scrape'} 
    @dalli_client = Dalli::Client.new('localhost:11211', options)
  end

  Scrape.new.scrape

end
