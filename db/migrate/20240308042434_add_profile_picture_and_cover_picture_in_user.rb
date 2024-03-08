class AddProfilePictureAndCoverPictureInUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :profile_picture, :string
    add_column :users, :cover_picture, :string
  end
end
