class CreateInitialSchema < ActiveRecord::Migration[7.1]
  def change
    # == users ==========================================================
    create_table :users, id: :bigint do |t|
      t.string :email, null: false
      t.string :encrypted_password, null: false
      t.string :name
      t.string :avatar_url, limit: 300
      t.string :role, limit: 30

      t.timestamps
    end
    add_index :users, :email, unique: true

    # == stocks =========================================================
    create_table :stocks, id: :bigint do |t|
      t.string :symbol, null: false, limit: 30
      t.string :name, limit: 250
      t.string :name_kr, limit: 250
      t.string :market, limit: 250
      t.string :sector, limit: 250

      t.timestamps
    end
    add_index :stocks, :symbol, unique: true

    # == posts ==========================================================
    create_table :posts, id: :bigint do |t|
      t.references :user,  null: false, foreign_key: true, type: :bigint
      t.references :stock, null: false, foreign_key: true, type: :bigint

      t.text :body
      t.text :image_url

      t.integer :likes_count,    null: false, default: 0
      t.integer :comments_count, null: false, default: 0

      t.timestamps
    end
    add_index :posts, [:stock_id, :created_at]

    # == comments =======================================================
    create_table :comments, id: :bigint do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint
      t.references :post, null: false, foreign_key: true, type: :bigint

      t.text :body
      t.integer :likes_count, null: false, default: 0

      t.timestamps
    end
    add_index :comments, [:post_id, :created_at]

    # == bookmarks (stock favorites) ====================================
    create_table :bookmarks, id: :bigint do |t|
      t.references :user,  null: false, foreign_key: true, type: :bigint
      t.references :stock, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
    add_index :bookmarks, [:user_id, :stock_id], unique: true

    # == post_likes =====================================================
    create_table :post_likes, id: :bigint do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint
      t.references :post, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
    add_index :post_likes, [:user_id, :post_id], unique: true

    # == comment_likes ==================================================
    create_table :comment_likes, id: :bigint do |t|
      t.references :user,    null: false, foreign_key: true, type: :bigint
      t.references :comment, null: false, foreign_key: true, type: :bigint

      t.timestamps
    end
    add_index :comment_likes, [:user_id, :comment_id], unique: true

    # == price_candles ==================================================
    create_table :price_candles, id: :bigint do |t|
      t.references :stock, null: false, foreign_key: true, type: :bigint

      t.datetime :time,     null: false
      t.string   :interval, null: false, limit: 20

      t.decimal :open,  precision: 15, scale: 4
      t.decimal :high,  precision: 15, scale: 4
      t.decimal :low,   precision: 15, scale: 4
      t.decimal :close, precision: 15, scale: 4
      t.bigint  :volume

      t.timestamps
    end
    add_index :price_candles, [:stock_id, :interval, :time], unique: true
  end
end