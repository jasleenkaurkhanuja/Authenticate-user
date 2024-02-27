class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.integer :reciever
      t.integer :sender

      t.timestamps
    end
  end
end
