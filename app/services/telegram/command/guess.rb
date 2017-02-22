require 'aspector'

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

    aspector(Guess, class_methods: true) do
      target do
        def permit(*args, &block)
          channel, message = *args
          Telegram::Validator.validate!(Action::GUESS, channel, message)
        end
      end

      before :execute, :permit
    end
  end
end
