# api
The main API for Rättvisekollen.

## Setup instructions
```bash
# install ruby
brew install ruby

# install bundler
gem install bundler

# install dependencies
bundle install

# start server
bundle exec rails server

# the api should now be running on http://localhost:3000
```


## Scraping
The scrapers can be run locally using rake tasks. To scrape products from ex. Matvaran, run
```bash
bundle exec rake scrape:matvaran
```
