class AddForeignKeyInBlock < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :blocks, :users, column: :blocker_id
    add_foreign_key :blocks, :users, column: :blocked_id
  end
end
