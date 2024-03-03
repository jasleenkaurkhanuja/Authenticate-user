class ChangeDataTypeInBlock < ActiveRecord::Migration[7.1]
  def change
    change_column :blocks, :blocked_id, :integer
  end
end
