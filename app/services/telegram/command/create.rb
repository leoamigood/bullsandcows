module Telegram
  module Command

    class Create
      class << self
        def execute(channel, message, options)
          Telegram::CommandQueue.clear
          case options[:strategy]
            when :by_word
              game = GameEngineService.create_by_word(Realm::Telegram.new(channel, message.from.id), options[:word])

            when :by_number
              settings = Setting.find_by_channel(channel)
              options = settings.options.merge(options) if settings.present?

              game = GameEngineService.create_by_options(Realm::Telegram.new(channel, message.from.id), options)

            else
              raise GameCreateException.new("Cannot create game with #{options[:strategy]} strategy!")
          end
          TelegramMessenger.game_created(game)
        end
      end
    end

  end
end
