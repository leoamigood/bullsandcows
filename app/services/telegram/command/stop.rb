module Telegram
  module Command

    class Stop
      class << self
        def execute(channel, message)
          game = GameService.find_by_channel!(channel)

          raise Errors::GameCommandStopNotPermittedException unless Telegram::Validator.permitted?(game, :stop, message)
          GameService.stop!(game)
        end
      end
    end

  end
end
