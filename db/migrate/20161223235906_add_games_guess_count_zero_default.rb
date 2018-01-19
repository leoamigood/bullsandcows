class AddGamesGuessCountZeroDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default :games, :guesses_count, 0
  end
end
