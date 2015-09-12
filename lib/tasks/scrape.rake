namespace :scrape do
  desc "Enqueue Matvaran urls to be scraped by the scraper"
  task matvaran: :environment do
    MatvaranEnqueuer.new.start
  end
end
