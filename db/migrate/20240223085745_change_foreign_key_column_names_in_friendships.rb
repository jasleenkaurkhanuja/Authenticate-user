class ChangeForeignKeyColumnNamesInFriendships < ActiveRecord::Migration[7.1]
  def change
    rename_column :friendships, :sender, :sender_id
    rename_column :friendships, :reciever, :reciever_id
  end
end
