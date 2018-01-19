class AddSuggestionsToGuess < ActiveRecord::Migration[5.1]
  def change
    add_column :guesses, :suggestion, :boolean, default: false
  end
end
