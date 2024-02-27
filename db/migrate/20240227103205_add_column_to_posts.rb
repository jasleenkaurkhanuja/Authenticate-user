class AddColumnToPosts < ActiveRecord::Migration[7.1]
  def change
    add_column :posts, :permission, :string, default: 'everyone' 
  end
end
