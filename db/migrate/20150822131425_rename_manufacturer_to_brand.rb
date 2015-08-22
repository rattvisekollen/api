class RenameManufacturerToBrand < ActiveRecord::Migration
  def change
    rename_column :products, :manufacturer_raw, :brand_raw
    rename_column :products, :manufacturer, :brand
  end
end
