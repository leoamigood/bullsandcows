require 'aspector'

module Telegram
  module Action

    class Create
      class << self
        def ask(channel)
          TelegramMessenger.ask_length(channel)
        end

        def execute(channel, user, options)
          realm = Realm::Telegram.new(channel, user)
          case options[:strategy]
            when :by_word
              game = GameEngineService.create_by_word(realm, options[:word])

            when :by_number
              settings = Setting.find_by_channel(channel)
              options = settings.options.merge(options) if settings.present?

              game = GameEngineService.create_by_options(realm, options)
          end
          TelegramMessenger.game_created(game)
        end

        def self?
          "proc { |cls| cls == #{self.name} }"
        end
      end
    end

    aspector(Create, class_methods: true) do
      target do
        def assert(*args, &block)
          channel = args.first
          Telegram::CommandQueue::Queue.new(channel).assert(self)
        end

        def permit(*args, &block)
          channel = args.first
          Telegram::Validator.validate!(Command::CREATE, channel)
        end

        def pop(*args, &block)
          msg, channel = *args
          Telegram::CommandQueue::Queue.new(channel).pop

          msg
        end
      end

      before_filter :execute, :assert
      before :ask, :execute, :permit
      after :execute, :pop
    end
  end
end
