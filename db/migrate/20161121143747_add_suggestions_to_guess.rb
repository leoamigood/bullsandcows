class AddSuggestionsToGuess < ActiveRecord::Migration
  def change
    add_column :guesses, :suggestion, :boolean, default: false
  end
end
