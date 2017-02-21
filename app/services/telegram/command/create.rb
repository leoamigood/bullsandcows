module Telegram
  module Command

    class Create
      class << self
        def execute(channel, message, options, strategy)
          Telegram::CommandQueue.clear
          game = GameEngineService.method(strategy).call(Realm::Telegram.new(channel, message.from.id), options)
          TelegramMessenger.game_created(game)
        end

        def create_by_options(channel, message, options)
          settings = Setting.find_by_channel(channel)
          options = settings.options.merge(options) if settings.present?

          execute(channel, message, options, :create_by_options)
        end
      end
    end

  end
end
