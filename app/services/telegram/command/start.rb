require 'aspector'

module Telegram
  module Command

    class Start
      class << self
        def execute(channel)
          Telegram::CommandQueue.clear
          TelegramMessenger.welcome(channel)

          Telegram::CommandQueue.push(Proc.new{ |c| c == Telegram::Command::Language }) { TelegramMessenger.ask_language(channel) }
          Telegram::CommandQueue.push(Proc.new{ |c| c == Telegram::Command::Level  }) { TelegramMessenger.ask_level(channel) }
          Telegram::CommandQueue.push(Proc.new{ |c| c == Telegram::Command::Create  }) { TelegramMessenger.ask_length(channel) }
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
