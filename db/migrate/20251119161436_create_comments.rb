class CreateComments < ActiveRecord::Migration[7.1]
  def change
    create_table :comments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :post, null: false, foreign_key: true

      t.text :body, null: false
      t.integer :likes_count, null: false, default: 0

      t.timestamps
    end

    add_index :comments, [:post_id, :created_at]
  end
end