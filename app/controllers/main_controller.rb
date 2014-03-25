require 'mechanize'
require 'open-uri'

class MainController < ApplicationController
  def scrape
    threads = []
    threads << Thread.new do
      @ga_reviews = fetch_site_data("http://www.greatandhra.com/reviews.php", "div.movies_page_news a") 
    end
    threads << Thread.new do
      @ib_reviews = fetch_site_data("http://idlebrain.com/movie/archive/index.html", 
                                    "html body table tr td table tr td table tr td table a", 
                                    "http://idlebrain.com/movie/archive/")      
    end
    threads << Thread.new do
      @gt_reviews = fetch_site_data("http://www.gulte.com/moviereviews", 
                                    "html body div.wrapper div.main div.container ul.list_more li a")        
    end
    threads.each(&:join)
  end
  
  def contact
  end
  
  private
  
  def fetch_site_data(url, css_path, base_url = "")
    reviews = []
    agent = Mechanize.new
    page = agent.get(url)
    reviews_count = 0
    page.parser.css(css_path).each do |link|
      break if reviews_count == 5
      reviews_count += 1
      l_map = {}
      l_map['href'] = base_url + link['href']
      l_map['text'] = link.text
      reviews << l_map
    end
    return reviews
  end
end
