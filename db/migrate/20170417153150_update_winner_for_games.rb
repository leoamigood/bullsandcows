class UpdateWinnerForGames < ActiveRecord::Migration[5.1]
  def change
    ActiveRecord::Base.transaction do
      Game.where(status: :finished).each do |game|
        game.winner_id = game.guesses.last.try(:user_id)
        game.save!
      end
    end
  end
end
