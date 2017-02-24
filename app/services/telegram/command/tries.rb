require 'aspector'

module Telegram
  module Command

    class Tries
      class << self
        def execute(channel)
          guesses = GameEngineService.tries(channel)
          TelegramMessenger.tries(guesses)
        end
      end
    end

    aspector(Tries, class_methods: true) do
      target do
        def permit(*args, &block)
          channel, message = *args
          Telegram::Validator.validate!(Action::TRIES, channel, message)
        end
      end

      before :execute, :permit
    end
  end
end
