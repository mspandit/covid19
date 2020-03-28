class CreateUsReports < ActiveRecord::Migration[5.2]
  def change
    create_table :us_reports do |t|
      t.string :county
      t.string :state
      t.integer :cases
      t.integer :deaths

      t.timestamps
    end
  end
end
