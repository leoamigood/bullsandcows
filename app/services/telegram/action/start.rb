require 'aspector'

module Telegram
  module Action

    class Start
      class << self
        def execute(channel)
          TelegramMessenger.welcome(channel)

          queue = Telegram::CommandQueue::Queue.new(channel).reset

          ask_language = Telegram::CommandQueue::Exec.new('TelegramMessenger.ask_language', channel, Telegram::Action::Language.self?)
          ask_level = Telegram::CommandQueue::Exec.new('TelegramMessenger.ask_level', channel, Telegram::Action::Level.self?)
          ask_length = Telegram::CommandQueue::Exec.new('TelegramMessenger.ask_length', channel, Telegram::Action::Create.self?)

          queue.push(ask_language, ask_level, ask_length)
        end
      end
    end

    private

    aspector(Start, class_methods: true) do
      target do
        def permit(*args, &block)
          channel, message = *args
          Telegram::Validator.validate!(Command::START, channel, message)
        end
      end

      before :execute, :permit
    end
  end
end
