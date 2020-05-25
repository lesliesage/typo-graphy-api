class ChangeResetColumnName < ActiveRecord::Migration[6.0]
  def change
    rename_column :users, :reset_password_token, :reset_password_code
  end
end
