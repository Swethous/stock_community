class CreatePosts < ActiveRecord::Migration[7.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true

      t.text :body, null: false

      t.integer :comments_count, null: false, default: 0
      t.integer :likes_count, null: false, default: 0

      t.timestamps
    end

    add_index :posts, [:stock_id, :created_at]
    add_index :posts, :created_at
  end
end