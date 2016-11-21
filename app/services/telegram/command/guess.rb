module Telegram
  module Command

    class Guess
      class << self
        def execute(channel, message, command)
          game = GameService.find_by_channel!(channel)
          guess = GameEngineService.guess(game, message.from.username, command)
          TelegramMessenger.guess(guess)
        end
      end
    end

  end
end
