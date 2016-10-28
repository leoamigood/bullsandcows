module Errors

  class GameNotExistsException < StandardError
  end

  class GameNotStartedException < StandardError
    attr_reader :game

    def initialize(game, message)
      @game = game
      super(message)
    end
  end

end
