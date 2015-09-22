class Product < ActiveRecord::Base
  serialize :ingredients, JSON

  belongs_to :raw_product
end
