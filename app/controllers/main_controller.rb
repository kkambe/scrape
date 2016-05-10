require 'mechanize'
require 'open-uri'
require_dependency 'movie_review'

######## Reference: http://ruby.bastardsbook.com/chapters/mechanize/

class MainController < ApplicationController

  def scrape
    @languages = APP_CONFIG[ 'languages' ]
    @site_reviews = {}
    @languages.each do | lang |
      @site_reviews[ lang ] = @site_reviews[ lang ] || {}
      APP_CONFIG[ lang ].keys.each do | site |
        @site_reviews[ lang ][ site ] = Rails.cache.fetch( "#{lang}_#{site}" )
      end
    end
    logger.debug "SITE REVIEWS::: #{@site_reviews.inspect}"
  end
  
  def contact
  end
  
end
