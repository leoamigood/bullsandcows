module Telegram
  module Action

    class Start
      class << self
        def execute(channel, prologue)
          TelegramMessenger.welcome(channel, prologue)

          queue = Telegram::CommandQueue::Queue.new(channel).reset

          ask_language = Telegram::CommandQueue::Exec.new('TelegramMessenger.ask_language', channel, Telegram::Action::Language.self?)
          ask_level = Telegram::CommandQueue::Exec.new('TelegramMessenger.ask_level', channel, Telegram::Action::Level.self?)
          ask_length = Telegram::CommandQueue::Exec.new('TelegramMessenger.ask_length', channel, Telegram::Action::Create.self?)

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
