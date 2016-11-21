module Telegram
  module Command

    class Stop
      class << self
        def execute(channel, message)
          if GameEngineService.stop_permitted?(message)
            game = GameService.find_by_channel!(channel)
            GameService.stop!(game)
            TelegramMessenger.game_stop(game)
          else
            TelegramMessenger.no_permissions_to_stop_game
          end
        end
      end
    end

  end
end
