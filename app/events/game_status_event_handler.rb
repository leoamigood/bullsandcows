class GameStatusEventHandler
  class << self
    def game_finished(payload)
      game = payload[:game]
      game.winner_id = game.guesses.last.user_id
      game.save!
    end
  end
end
