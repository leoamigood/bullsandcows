module Telegram
  module Command

    class Stop
      class << self
        def execute(channel)
          game = GameService.find_by_channel!(channel)
          GameService.stop!(game)
        end

        def validate(message)
          raise Errors::GameCommandStopNotPermittedException unless Telegram::Validator.permitted?(:stop, message)
        end
      end
    end

  end
end
