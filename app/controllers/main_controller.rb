require 'mechanize'
require 'open-uri'

######## Reference: http://ruby.bastardsbook.com/chapters/mechanize/

class MainController < ApplicationController
  def scrape
    @site_map = APP_CONFIG['site_map']
    @site_reviews = {}
    logger.debug "SITE MAP======== " + @site_map.inspect
    @site_map.each do |lang, site_list|
      @site_reviews[lang] = {}
      site_list.each do |site|
        @site_reviews[lang][site] = Rails.cache.fetch("#{lang}_#{site}")
      end
    end
    logger.debug "SITE REVIEWS MAP======== " + @site_reviews.inspect
  end
  
  def contact
  end
  
end
