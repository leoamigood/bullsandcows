require 'aspector'

module Telegram
  module Command

    class Suggest
      class << self
        def execute(channel, message, letters)
          game = GameService.find_by_channel!(channel)
          guess = GameEngineService.suggest(game, User.new(message.from.id, message.from.username), letters)

          guess.present? ? TelegramMessenger.suggestion(guess) : TelegramMessenger.no_suggestions(letters)
        end
      end
    end

    aspector(Suggest, class_methods: true) do
      target do
        def permit(*args, &block)
          channel, message = *args
          Telegram::Validator.validate!(Action::SUGGEST, channel, message)
        end
      end

      before :execute, :permit
    end
  end
end
