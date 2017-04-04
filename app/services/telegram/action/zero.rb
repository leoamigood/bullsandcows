require 'aspector'

module Telegram
  module Action

    class Zero
      class << self
        def execute(channel)
          guesses = GameEngineService.zero(channel)
          TelegramMessenger.zero(guesses)
        end
      end
    end

    private

    aspector(Zero, class_methods: true) do
      target do
        def permit(*args, &block)
          channel, message = *args
          Telegram::Validator.validate!(Command::ZERO, channel, message)
        end
      end

      before :execute, :permit
    end
  end
end
