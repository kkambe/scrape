#!/usr/bin/ruby

require 'dalli'
require 'mechanize'
require 'open-uri'
require 'yaml'
require 'json'
require_relative 'scrape_detail'

class Scrape

  RAILS_ROOT = "#{File.dirname(__FILE__)}/.."
  @@site_hash = {}

  attr_accessor :dalli_client

  def scrape
    @@site_hash.each do |lang, l_map|
      puts "Language: #{lang}"
      l_map.each do |site, s_detail|
        puts "Site: #{site}"
        review_details = fetch_site_data(s_detail["url"], s_detail["css_path"], s_detail["base_url"], s_detail["rating_css_path"])
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

  def load_json
    properties = YAML.load_file( "#{RAILS_ROOT}/config/config.yml" )
    puts "PROPERTIES: #{properties.inspect}"
    properties[ "languages" ].each do | l |
      json_file = File.read( "#{RAILS_ROOT}/config/#{l}.json" )
      @@site_hash[ l ] = JSON.parse( json_file )
    end
    puts "@@SITE_HASH: #{@@site_hash.inspect}"
  end

  # TODO: For each language and for each website 
  #       1) fetch the ratings of latest 5 movies 
  #       2) save them in memcached.
  #
  def initialize
    options = {:namespace => 'scrape'} 
    @dalli_client = Dalli::Client.new('localhost:11211', options)
    load_json
  end

  Scrape.new.scrape

end
