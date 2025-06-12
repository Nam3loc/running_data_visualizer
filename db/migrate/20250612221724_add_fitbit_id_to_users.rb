class AddFitbitIdToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :fitbit_id, :string
  end
end
