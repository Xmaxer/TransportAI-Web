class CreateSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :settings do |t|
      t.float :price_per_km
      t.float :price_per_time

      t.timestamps
    end
  end
end
