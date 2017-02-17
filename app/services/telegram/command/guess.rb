module Telegram
  module Command

    class Guess
      class << self
        def execute(channel, message, word)
          game = GameService.find_by_channel!(channel)
          guess = GameEngineService.guess(game, User.new(message.from.id, message.from.username), word)
          TelegramMessenger.guess(guess)
        end
      end
    end

  end
end
