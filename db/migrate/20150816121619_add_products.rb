class AddProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :source
      t.string :source_url

      t.string :barcode

      t.string :img_url

      t.string :name
      t.string :name_raw

      t.string :manufacturer
      t.string :manufacturer_raw

      t.string :origin
      t.string :origin_raw

      t.text :ingredients
      t.text :ingredients_raw

      t.timestamps null: false
    end

    add_index :products, :barcode, unique: true
  end
end
