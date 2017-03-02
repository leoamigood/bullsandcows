require 'aspector'

module Telegram
  module Command

    class Create
      class << self
        def ask(channel)
          TelegramMessenger.ask_length(channel)
        end

        def execute(channel, message, options)
          Telegram::CommandQueue.clear

          case options[:strategy]
            when :by_word
              game = GameEngineService.create_by_word(Realm::Telegram.new(channel, message.from.id), options[:word])

            when :by_number
              settings = Setting.find_by_channel(channel)
              options = settings.options.merge(options) if settings.present?

              game = GameEngineService.create_by_options(Realm::Telegram.new(channel, message.from.id), options)
          end
          TelegramMessenger.game_created(game)
        end
      end
    end

    aspector(Create, class_methods: true) do
      target do
        def permit(*args, &block)
          channel, message = *args
          Telegram::Validator.validate!(Action::CREATE, channel, message)
        end
      end

      before :ask, :execute, :permit
    end
  end
end
