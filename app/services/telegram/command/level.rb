require 'aspector'

module Telegram
  module Command

    class Level
      class << self
        def ask(channel)
          TelegramMessenger.ask_level(channel)
        end

        def execute(channel, level)
          Telegram::CommandQueue.assert(self)

          GameEngineService.settings(channel, { complexity: level })
          TelegramMessenger.level(level)
        end
      end
    end

    aspector(Level, class_methods: true) do
      target do
        def permit(*args, &block)
          channel, message = *args
          Telegram::Validator.validate!(Action::LEVEL, channel, message)
        end
      end

      before :ask, :execute, :permit
    end
  end
end
