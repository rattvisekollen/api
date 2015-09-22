class InitialSetup < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :barcode
      t.string :name
      t.string :name_secondary
      t.string :manufacturer
      t.string :brand
      t.string :origin
      t.text :ingredients
      t.text :img_urls

      t.boolean :krav, default: false
      t.boolean :eu_organic, default: false
      t.boolean :eu_ecolabel, default: false
      t.boolean :fairtrade, default: false
      t.boolean :rainforest_alliance, default: false
      t.boolean :nyckelhalet, default: false
      t.boolean :co_compensated, default: false
      t.boolean :anglamark, default: false
      t.boolean :garant, default: false
      t.boolean :msc, default: false
      t.boolean :natrue, default: false
      t.boolean :naturbete, default: false
      t.boolean :svensk_fagel, default: false
      t.boolean :sadesaxet, default: false

      t.integer :raw_product_id

      t.timestamps null: false
    end

    create_table :raw_products do |t|
      t.string :source
      t.string :source_url
      t.string :barcode
      t.string :name
      t.string :name_secondary
      t.string :manufacturer
      t.string :brand
      t.string :origin
      t.text :ingredients
      t.text :img_urls

      t.boolean :krav, default: false
      t.boolean :eu_organic, default: false
      t.boolean :eu_ecolabel, default: false
      t.boolean :fairtrade, default: false
      t.boolean :rainforest_alliance, default: false
      t.boolean :nyckelhalet, default: false
      t.boolean :co_compensated, default: false
      t.boolean :anglamark, default: false
      t.boolean :garant, default: false
      t.boolean :msc, default: false
      t.boolean :natrue, default: false
      t.boolean :naturbete, default: false
      t.boolean :svensk_fagel, default: false
      t.boolean :sadesaxet, default: false

      t.timestamps null: false
    end
  end
end
