class ScrapeWeb

  def initialize
    options = {:namespace => 'scrape'} 
    @dalli_client = Dalli::Client.new('localhost:11211', options)
    @limit = 5
  end

  def update_ratings
    scrape
  end

  private

  def scrape
    langs = APP_CONFIG[ 'languages' ]
    langs.each do | lang |
      l_det = APP_CONFIG[ lang ]
      l_det.each do | w, w_det |
        review_details = fetch_site_data( w_det[ "url" ], w_det[ "css_path" ], w_det[ "base_url" ], w_det[ "rating_css_path" ] )
        @dalli_client.set("#{lang}_#{w}", review_details);
      end
    end
  end

  def fetch_site_data( url, css_path, base_url, rating_css_path )
    reviews = []
    page = Mechanize.new.get( url )
    reviews_count = 0
    page.parser.css( css_path ).each do | link |
      break if reviews_count == @limit
      reviews_count += 1
      l_map = {}
      rev_url = base_url + link[ 'href' ]
      title = link.text
      rating = get_rating( rev_url, rating_css_path )
      movie_review = MovieReview.new( rev_url, title, rating )
      reviews << movie_review
    end
    reviews
  end

  def get_rating(url, rating_css_path)
    rating = "N/A"
    begin
      page = Mechanize.new.get(url)
      res = page.parser.css(rating_css_path)[0]
      Rails.logger.debug "URL======== " + url.inspect
      Rails.logger.debug "CSS PATH======== " + rating_css_path.inspect
      Rails.logger.debug "RESULT======== " + res.inspect
      rating = res.text
    rescue Exception => e
      Rails.logger.error "Exception while retrieving rating::: " + e.backtrace.inspect        
    end
    rating
  end

end
