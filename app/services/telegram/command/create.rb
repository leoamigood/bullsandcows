module Telegram
  module Command

    class Create
      class << self
        def execute(channel, options, strategy)
          Telegram::CommandQueue.clear
          game = GameEngineService.method(strategy).call(channel, :telegram, options)
          TelegramMessenger.game_created(game)
        end

        def create_by_options(channel, options)
          settings = Setting.find_by_channel(channel)
          options = settings.options.merge(options) if settings.present?

          execute(channel, options, :create_by_options)
        end
      end
    end

  end
end
