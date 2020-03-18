class CreateAuthors < ActiveRecord::Migration[5.2]
  def change
    create_table :authors do |t|
      t.string :first
      t.string :middle
      t.string :last
      t.string :suffix
      t.string :laboratory
      t.string :institution
      t.string :addr_line
      t.string :post_code
      t.string :settlement
      t.string :country

      t.timestamps
    end
  end
end
