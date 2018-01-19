class AddCountToGuess < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :guesses_count, :integer
  end
end
