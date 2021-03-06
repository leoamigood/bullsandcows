module Errors

  class ValidationException < StandardError
    def initialize(parameter)
      super("Invalid parameter key: #{parameter.first} value: #{parameter.last}")
    end
  end

  class TelegramIOException < StandardError
  end

  class GameException < StandardError
    attr_reader :game

    def initialize(message, game = nil)
      @game = game
      super(message)
    end
  end

  class VoiceMessageException < GameException
  end

  class GuessException < GameException
  end

  class GameNotFoundException < GameException
  end

  class GameCreateException < GameException
  end

  class GameNotRunningException < GameException
  end

  class PermissionException < GameException
  end

  class CommandNotPermittedException < PermissionException
  end

end
