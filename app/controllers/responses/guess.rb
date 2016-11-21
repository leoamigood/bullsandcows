module Responses
  class Guess < Response

    def initialize(guess)
      @link = link(guess)
      @word = guess.word
      @bulls = guess.bulls
      @cows = guess.cows
      @attempts = guess.attempts
      @exact = guess.exact
    end

    def link(guess)
      "/games/#{guess.game.id}/guesses/#{guess.id}"
    end
  end
end
