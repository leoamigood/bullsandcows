module Telegram
  module Command

    class Suggest
      class << self
        def execute(channel, message, letters)
          game = GameService.find_by_channel!(channel)
          guess = GameEngineService.suggest(game, message.from.username, letters)

          guess.present? ? TelegramMessenger.suggestion(guess) : TelegramMessenger.no_suggestions(letters)
        end
      end
    end

  end
end
