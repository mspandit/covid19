class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.integer :region_id
      t.integer :confirmed
      t.integer :deaths
      t.integer :recovered

      t.timestamps
    end
  end
end
