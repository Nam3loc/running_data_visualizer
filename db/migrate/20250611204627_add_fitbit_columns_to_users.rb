class AddFitbitColumnsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :fitbit_token, :string
    add_column :users, :fitbit_refresh_token, :string
    add_column :users, :fitbit_token_expires_at, :datetime
  end
end
