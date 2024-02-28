class AddColumnVerificationToUser < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :verification, :string, default: false
    add_column :users, :token, :string
    #Ex:- :default =>''
    #Ex:- add_column("admin_users", "username", :string, :limit =>25, :after => "email")
  end
end
