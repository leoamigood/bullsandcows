module Telegram
  module Command

    class Create
      class << self
        def execute(channel, command, strategy)
          Telegram::CommandQueue.clear
          game = GameEngineService.method(strategy).call(channel, command, :telegram)
          TelegramMessenger.game_created(game)
        end
      end
    end

  end
end
