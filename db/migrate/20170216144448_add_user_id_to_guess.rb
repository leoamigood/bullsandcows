class AddUserIdToGuess < ActiveRecord::Migration
  def change
    add_column :guesses, :user_id, :integer
  end
end
