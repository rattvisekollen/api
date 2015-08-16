class Product < ActiveRecord::Base
  serialize :ingredients, JSON
end
