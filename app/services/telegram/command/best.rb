require 'aspector'

module Telegram
  module Command

    class Best
      class << self
        def execute(channel, limit)
          guesses = GameEngineService.best(channel, limit)
          TelegramMessenger.best(guesses)
        end
      end
    end

    aspector(Best, class_methods: true) do
      target do
        def permit(*args, &block)
          channel, message = *args
          Telegram::Validator.validate!(Telegram::Command::Action::BEST, channel, message)
        end
      end

      before :execute, :permit
    end
  end
end
