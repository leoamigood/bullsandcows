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

end
