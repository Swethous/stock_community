class CreatePriceCandles < ActiveRecord::Migration[7.1]
  def change
    create_table :price_candles do |t|
      t.references :stock, null: false, foreign_key: true

      t.datetime :time, null: false
      t.string   :interval, null: false      # '1m', '5m', '1d' 등

      t.decimal  :open,  precision: 15, scale: 4
      t.decimal  :high,  precision: 15, scale: 4
      t.decimal  :low,   precision: 15, scale: 4
      t.decimal  :close, precision: 15, scale: 4
      t.bigint   :volume

      t.timestamps
    end

    add_index :price_candles, [:stock_id, :interval, :time], unique: true
    add_index :price_candles, [:stock_id, :time]
  end
end