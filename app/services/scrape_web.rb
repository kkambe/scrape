class ScrapeWeb

  def initialize
    options = {:namespace => 'scrape'} 
    @dalli_client = Dalli::Client.new('localhost:11211', options)
    @limit = 5
    @invalid_rating = "N/A"
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
      l_map = {}
      rev_url = base_url + link[ 'href' ]
      rating = get_rating( rev_url, rating_css_path )
      if rating != @invalid_rating
        title = get_processed_title link.text
        movie_review = MovieReview.new( rev_url, title, rating )
        reviews << movie_review
        reviews_count += 1
      end
    end
    reviews
  end

  def get_rating(url, rating_css_path)
    rating = @invalid_rating
    begin
      page = Mechanize.new.get(url)
      res = page.parser.css(rating_css_path)[0]
      Rails.logger.debug "URL======== " + url.inspect
      Rails.logger.debug "CSS PATH======== " + rating_css_path.inspect
      Rails.logger.debug "RESULT======== " + res.inspect
      rating = extract_rating_from_text res.text
    rescue Exception => e
      Rails.logger.error "Exception while retrieving rating::: " + e.backtrace.inspect        
    end
    rating
  end

  def extract_rating_from_text txt
    rating = txt.gsub(/stars/i, '').strip.split("/")[0].strip.split(" ")[-1].gsub(/-/i, '')
    if is_valid_rating rating
      rating
    else
      @invalid_rating
    end
  end

  def is_valid_rating rating
    true if Float( rating ) rescue false
  end

  def get_processed_title title
    title.gsub( /review/i, '' ).strip.gsub(/^:/i, '').strip.split(' ').join(' ')
  end

end
