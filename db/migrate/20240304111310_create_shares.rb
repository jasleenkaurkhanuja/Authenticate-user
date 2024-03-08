class CreateShares < ActiveRecord::Migration[7.1]
  def change
    create_table :shares do |t|
      t.integer :original_id
      t.integer :user_id
      t.integer :post_id

      t.timestamps
    end
  end
end
