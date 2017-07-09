module Telegram
  module Action

    class Start
      class << self
        def execute(channel, prologue)
          TelegramMessenger.welcome(channel, prologue)

          queue = CommandQueue::Queue.new(channel).reset

          ask_language = CommandQueue::Exec.new('Telegram::TelegramMessenger.ask_language', channel, Telegram::Action::Language.self?)
          ask_level = CommandQueue::Exec.new('Telegram::TelegramMessenger.ask_level', channel, Telegram::Action::Level.self?)
          ask_length = CommandQueue::Exec.new('Telegram::TelegramMessenger.ask_length', channel, Telegram::Action::Create.self?)

          queue.push(ask_language, ask_level, ask_length)
        end

        private

        def command
          Command::START
        end
      end
    end

    Rules::PermitExecute.apply(Start, class_methods: true)
  end
end
