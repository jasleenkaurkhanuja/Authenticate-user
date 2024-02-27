class CreateFriendships < ActiveRecord::Migration[7.1]
  def change
    create_table :friendships do |t|
      t.integer :sender
      t.integer :reciever

      t.timestamps
    end
  end
end
