module Telegram
  module Command

    class Start
      class << self
        def execute(channel)
          TelegramMessenger.welcome(channel)
          TelegramMessenger.ask_level(channel)

          Telegram::CommandQueue.push{ TelegramMessenger.ask_language(channel) }
          Telegram::CommandQueue.push{ TelegramMessenger.ask_length(channel) }
        end
      end
    end

  end
end
