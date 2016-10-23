class GameService

  class << self
    def create(channel, secret, source = nil)
      Game.create({channel: channel, secret: secret.noun, level: secret.level, dictionary: secret.dictionary, source: source})
    end

    def find!(channel)
      game = Game.where(channel: channel).last
      raise "Failed to find the game. Is game started for telegram message chat ID: #{channel}" unless game.present?

      game
    end

    def guess(game, username, word)
      guess = Guess.where(game_id: game.id, word: word).take
      if (guess.nil?)
        match = GuessService.match(word, game.secret)
        guess = Guess.create(match.merge(game_id: game.id, username: username, attempts: 1))

        game.status = match[:exact].present? ? :finished : :running
        game.save!
      else
        guess.attempts += 1
        guess.save!
      end
      guess
    end

    def hint(game)
      letter = game.secret[rand(game.secret.length)]
      game.hints += 1
      game.save!

      letter
    end

    def stop!(game)
      raise 'Game has already finished. Please start a new game using _/create_ command.' if game.finished?

      game.finished!
      game.save!
    end

    def is_running?(game)
      raise 'Game has finished. Please start a new game using _/create_ command.' if game.finished?
    end

    def validate_guess!(game, guess)
      # raise "Guess _#{guess}_ is not in dictionary, please try another word." unless Noun.find_by_noun(guess).present?
      raise "Your guess word _#{guess}_ has to be *#{game.secret.length}* letters long." if game.secret.length != guess.length
    end
  end

end
