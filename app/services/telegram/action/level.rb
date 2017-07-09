require 'aspector'

module Telegram
  module Action

    class Level
      class << self
        def ask(channel)
          TelegramMessenger.ask_level(channel)
        end

        def execute(channel, level)
          GameEngineService.settings(channel, { complexity: level })
          TelegramMessenger.level(level)
        end

        def self?
          "proc { |cls| cls == #{self.name} }"
        end
      end
    end

    private

    aspector(Level, class_methods: true) do
      target do
        def assert(*args, &block)
          channel = args.first
          CommandQueue::Queue.new(channel).assert(self)
        end

        def permit(*args, &block)
          channel, message = *args
          Telegram::Validator.validate!(Command::LEVEL, channel, message)
        end

        def pop(*args, &block)
          msg, channel = *args
          CommandQueue::Queue.new(channel).pop

          msg
        end
      end

      before_filter :execute, :assert
      before :ask, :execute, :permit
      after :execute, :pop
    end
  end
end
