class AddColumnToFriendships < ActiveRecord::Migration[7.1]
  def change
    add_column :friendships, :status, :string
  end
end
