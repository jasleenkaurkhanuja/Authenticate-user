class ChnageDefaultInUserVerification < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :verification, 'false'
  end
end
