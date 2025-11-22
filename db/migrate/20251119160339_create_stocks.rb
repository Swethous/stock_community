class CreateStocks < ActiveRecord::Migration[7.1]
  def change
    create_table :stocks do |t|
      t.string :symbol, null: false
      t.string :name_ja
      t.string :name_en
      t.string :market
      t.string :sector

      t.timestamps
    end

    add_index :stocks, :symbol, unique: true
  end
end