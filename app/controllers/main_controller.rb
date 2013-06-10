require 'mechanize'
require 'open-uri'

class MainController < ApplicationController
  def scrape
    threads = []
    
    threads << Thread.new do
      @ga_reviews = []
      ga_url = "http://www.greatandhra.com/reviews.php"
      ga_base_url = "http://www.greatandhra.com/"
      ga_agent = Mechanize.new
      ga_page = ga_agent.get(ga_url)
      reviews_count = 0
      ga_page.parser.css('div.movies_page_news a').each do |l|
        break if reviews_count == 5
        reviews_count += 1
        l_map = {}
        l_map['href'] = ga_base_url + l['href']
        l_map['text'] = l.text
        @ga_reviews << l_map
      end  
    end
    
    threads << Thread.new do
      @ib_reviews = []
      ib_url = "http://idlebrain.com/movie/archive/index.html"
      ib_base_url = "http://idlebrain.com/movie/archive/"
      ib_agent = Mechanize.new
      ib_page = ib_agent.get(ib_url)
      reviews_count = 0
      ib_page.parser.css('html body table tr td table tr td table tr td table a').each do |link|
        break if reviews_count == 5
        reviews_count += 1
        l_map = {}
        l_map['href'] = ib_base_url + link['href']
        l_map['text'] = link.text
        @ib_reviews << l_map
      end      
    end
    
    threads << Thread.new do
      @gt_reviews = []
      gt_url = "http://www.gulte.com/moviereviews"
      #gt_css_path = 'html body div.wrapper div.container div.article div.listView a'
      gt_css_path = 'html body div.wrapper div.main div.container ul.list_more li a'
      gt_agent = Mechanize.new
      gt_page = gt_agent.get(gt_url)
      reviews_count = 0
      gt_page.parser.css(gt_css_path).each do |gtr|
        break if reviews_count == 5
        reviews_count += 1
        l_map = {}
        l_map['href'] = gtr['href']
        l_map['text'] = gtr.text
        @gt_reviews << l_map
      end      
    end
    
    threads.each(&:join)
    
  end
  
  def contact
    
  end
end
