class ChangeOtpDefault < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :otp, nil
  end
end
