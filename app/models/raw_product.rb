class RawProduct < ActiveRecord::Base
  def self.from_hash(hash)
    if hash[:barcode]
      self.find_or_create_by(barcode: hash[:barcode])
    else
      self.find_or_create_by(source: hash[:source], name: hash[:name])
    end.tap do |raw_product|
      raw_product.update!(hash)
    end
  end
end
