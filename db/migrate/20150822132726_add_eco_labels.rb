
class AddEcoLabels < ActiveRecord::Migration
  def change
    add_column :products, :krav, :boolean, default: false, null: false
    add_column :products, :eu_organic, :boolean, default: false, null: false
    add_column :products, :eu_ecolabel, :boolean, default: false, null: false
    add_column :products, :fairtrade, :boolean, default: false, null: false
    add_column :products, :rainforest_alliance, :boolean, default: false, null: false
    add_column :products, :nyckelhalet, :boolean, default: false, null: false
    add_column :products, :co_compensated, :boolean, default: false, null: false
    add_column :products, :anglamark, :boolean, default: false, null: false
    add_column :products, :garant, :boolean, default: false, null: false
    add_column :products, :msc, :boolean, default: false, null: false
    add_column :products, :natrue, :boolean, default: false, null: false
    add_column :products, :naturbete, :boolean, default: false, null: false
    add_column :products, :svensk_fagel, :boolean, default: false, null: false
    add_column :products, :sadesaxet, :boolean, default: false, null: false
  end
end
