require 'mechanize'
require 'open-uri'

######## Reference: http://ruby.bastardsbook.com/chapters/mechanize/

class MainController < ApplicationController
  def scrape
    threads = []
    threads << Thread.new do
      @ga_reviews = fetch_site_data("http://www.greatandhra.com/reviews.php", "div.movies_page_news a", 
                                    "html body div.content span p strong span") 
    end
    threads << Thread.new do
      @ib_reviews = fetch_site_data("http://idlebrain.com/movie/archive/index.html", 
                                    "html body table tr td table tr td table tr td table a", 
                                    "http://idlebrain.com/movie/archive/", 
                                    "html body table tbody tr td p font b font")      
    end
    threads << Thread.new do
      @gt_reviews = fetch_site_data("http://www.gulte.com/moviereviews", 
                                    "html body div.wrapper div.main div.container ul.list_more li a", 
                                    "html body .rating span")        
    end
    threads.each(&:join)
  end
  
  def contact
  end
  
  private
  
  def fetch_site_data(url, css_path, base_url = "", rating_css_path)
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
    return reviews
  end
  
  def get_rating(url, rating_css_path)
    rating = "N/A"
    begin
      page = Mechanize.new.get(url)
      res = page.parser.css(rating_css_path)[0]
      logger.debug "URL======== " + url.inspect
      logger.debug "CSS PATH======== " + rating_css_path.inspect
      logger.debug "RESULT======== " + res.inspect
      rating = res.text
    rescue Exception => e
      logger.error "Exception while retrieving rating::: " + e.backtrace.inspect        
    end
    return rating
  end
end
