require 'aspector'

module Telegram
  module Command

    class Stop
      class << self
        def execute(channel, message)
          game = GameService.find_by_channel!(channel)
          GameService.stop!(game)
          TelegramMessenger.game_stop(game)
        end
      end
    end

    aspector(Stop, class_methods: true) do
      target do
        def permit(*args, &block)
          channel, message = *args
          Telegram::Validator.validate!(Action::STOP, channel, message)
        end
      end

      before :execute, :permit
    end
  end
end
