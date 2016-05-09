
namespace :scrape do
  desc "scrapes multiple websites, fetches ratings of different movies and updates memcached"
  task web: :environment do
    ScrapeWeb.new.update_ratings
  end
end
