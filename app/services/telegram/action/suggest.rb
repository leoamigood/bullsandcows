require 'aspector'

module Telegram
  module Action

    class Suggest
      class << self
        def execute(channel, user, letters)
          game = GameService.find_by_channel!(channel)
          guess = GameEngineService.suggest(game, user, letters)

          guess.present? ? TelegramMessenger.suggestion(guess) : TelegramMessenger.no_suggestions(letters)
        end
      end
    end

    private

    aspector(Suggest, class_methods: true) do
      target do
        def permit(*args, &block)
          channel = *args
          Telegram::Validator.validate!(Command::SUGGEST, channel)
        end
      end

      before :execute, :permit
    end
  end
end
