class AddUserToGuess < ActiveRecord::Migration[5.1]
  def change
    add_column :guesses, :username, :string, after: :word
  end
end
