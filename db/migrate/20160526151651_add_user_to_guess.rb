class AddUserToGuess < ActiveRecord::Migration
  def change
    add_column :guesses, :username, :string, after: :word
  end
end
