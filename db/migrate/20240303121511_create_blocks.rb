class CreateBlocks < ActiveRecord::Migration[7.1]
  def change
    create_table :blocks do |t|
      t.integer :blocker_id
      t.string :blocked_id

      t.timestamps
    end
  end
end
