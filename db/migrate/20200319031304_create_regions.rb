class CreateRegions < ActiveRecord::Migration[5.2]
  def change
    create_table :regions do |t|
      t.string :province
      t.string :country
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
