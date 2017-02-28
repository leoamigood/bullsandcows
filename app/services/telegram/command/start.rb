require 'aspector'

module Telegram
  module Command

    class Start
      class << self
        def execute(channel)
          Telegram::CommandQueue.clear
          TelegramMessenger.welcome(channel)
          TelegramMessenger.ask_language(channel)

          Telegram::CommandQueue.to_confirm { |cls| cls == Telegram::Command::Language }
          Telegram::CommandQueue.push{ TelegramMessenger.ask_level(channel) }.to_confirm { |cls| cls == Telegram::Command::Level }
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
