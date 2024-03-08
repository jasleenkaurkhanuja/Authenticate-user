class AddToShare < ActiveRecord::Migration[7.1]
  def change
    add_foreign_key :shares, :users, column: :user_id 
    add_foreign_key :shares, :users, column: :original_id 
    add_foreign_key :shares, :posts, column: :post_id
  end
end
