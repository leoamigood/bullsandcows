require 'aspector'

module Telegram
  module Action

    class Stop
      class << self
        def execute(channel, message)
          game = GameService.find_by_channel!(channel)
          GameService.stop!(game)
          TelegramMessenger.game_stop(game)
        end

        private

        def command
          Command::STOP
        end
      end
    end

    Rules::PermitExecute.apply(Stop, class_methods: true)
  end
end
