class MovieReview

  attr_accessor :url, :title, :rating

  def initialize( url, title, rating )
    @url = url
    @title = title
    @rating = rating
  end

end

