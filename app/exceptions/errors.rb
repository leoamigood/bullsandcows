module Errors

  class ValidationException < StandardError
    def initialize(parameter)
      super("Invalid parameter key: #{parameter.first} value: #{parameter.last}")
    end
  end

  class GameNotFoundException < StandardError
  end

  class GameNotStartedException < StandardError
    attr_reader :game

    def initialize(game, message)
      @game = game
      super(message)
    end
  end

  class GameCreateException < StandardError
  end

  class PermissionException < StandardError
  end

  class GameCommandStopNotPermittedException < PermissionException
    def initialize
      super('You are NOT allowed to _/stop_ this game. Only _admin_ or _creator_ is')
    end
  end

end
