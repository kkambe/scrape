class ScrapeDetail

  attr_accessor :url, :css_path, :base_url, :rating_css_path

  def initialize(url, css_path, base_url, rating_css_path)
    puts "ScrapeDetail object"
    @url = url
    @css_path = css_path
    @base_url = base_url
    @rating_css_path = rating_css_path
  end

end
