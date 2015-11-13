require 'mechanize'
require 'open-uri'

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
  end
  
  def contact
  end
  
end
