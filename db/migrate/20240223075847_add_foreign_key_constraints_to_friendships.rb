class AddForeignKeyConstraintsToFriendships < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :friendships, :users, column: :sender
    add_foreign_key :friendships, :users, column: :reciever
  end
end
