class DropShare1 < ActiveRecord::Migration[7.1]
  def change
    drop_table :shares
  end
end
