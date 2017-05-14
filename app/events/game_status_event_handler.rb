class GameStatusEventHandler
  class << self
    def game_finished(payload)
      game = payload[:game]
      GameService.update_winner(game)
      GameService.score(game)
    end
  end
end
