class AddGamesGuessCountZeroDefault < ActiveRecord::Migration
  def change
    change_column_default :games, :guesses_count, 0
  end
end
