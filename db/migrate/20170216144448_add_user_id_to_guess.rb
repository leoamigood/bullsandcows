class AddUserIdToGuess < ActiveRecord::Migration[5.1]
  def change
    add_column :guesses, :user_id, :integer
  end
end
