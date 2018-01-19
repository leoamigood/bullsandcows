class AddUserIdToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :user_id, :integer
  end
end
