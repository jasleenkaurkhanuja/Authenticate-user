class AddForeignKeyConstraintsToNotifications < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :friendships, :users, column: :sender_id
    add_foreign_key :friendships, :users, column: :reciever_id
  end
end
