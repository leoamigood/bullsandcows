module Responses
  class Game < Response

    def initialize(game)
      @link = Game.link(game)
      @source = game.source
      @status = game.status
      @secret = '*' * game.secret.length
      @language = game.dictionary.try(:lang)
      @tries = game.guesses.count
      @hints = game.hints.count
    end

    class << self
      def link(game)
        "/games/#{game.id}"
      end

      def stats(game)
        {
            tries: game.guesses.count,
            hints: game.hints.count
        }
      end
    end
  end
end
