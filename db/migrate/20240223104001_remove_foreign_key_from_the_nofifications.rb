class RemoveForeignKeyFromTheNofifications < ActiveRecord::Migration[7.1]
  def change
    rename_column :notifications, :reciever, :reciever_id
    rename_column :notifications, :sender, :sender_id

    add_foreign_key :notifications, :users, column: :reciever_id
    add_foreign_key :notifications, :users, column: :sender_id
  end
end
