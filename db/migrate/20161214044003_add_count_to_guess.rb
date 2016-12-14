class AddCountToGuess < ActiveRecord::Migration
  def change
    add_column :games, :guesses_count, :integer
  end
end
