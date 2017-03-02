require 'aspector'

module Telegram
  module Command

    class Start
      class << self
        def execute(channel)
          Telegram::CommandQueue.clear
          TelegramMessenger.welcome(channel)

          Telegram::CommandQueue.push{ TelegramMessenger.ask_language(channel) }.callback { |cls| cls == Telegram::Command::Language }
          Telegram::CommandQueue.push{ TelegramMessenger.ask_level(channel) }.callback { |cls| cls == Telegram::Command::Level }
          Telegram::CommandQueue.push{ TelegramMessenger.ask_length(channel) }
        end
      end
    end

    aspector(Start, class_methods: true) do
      target do
        def permit(*args, &block)
          channel, message = *args
          Telegram::Validator.validate!(Action::START, channel, message)
        end
      end

      before :execute, :permit
    end
  end
end
