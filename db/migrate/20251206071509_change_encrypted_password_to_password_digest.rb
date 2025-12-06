class ChangeEncryptedPasswordToPasswordDigest < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :encrypted_password, :string

    add_column :users, :password_digest, :string, null: false
  end
end