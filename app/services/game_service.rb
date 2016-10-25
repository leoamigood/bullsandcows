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
        match = match(word, game.secret)
        guess = Guess.create(match.merge(game_id: game.id, username: username, attempts: 1))

        game.status = match[:exact].present? ? :finished : :running
        game.save!
      else
        guess.attempts += 1
        guess.save!
      end
      guess
    end

    def match(guess, secret)
      bulls = bulls(guess.split(''), secret.split(''))
      cows = cows(guess.split(''), secret.split(''))

      return {word: guess, bulls: bulls.compact.count, cows: cows.compact.count, exact: guess == secret}
    end

    def bulls(guess, secret)
      guess.zip(secret).map { |(g, s)| g == s ? g : nil}
    end

    def cows(guess, secret)
      bulls = bulls(guess, secret)
      guess, secret = guess.zip(secret, bulls).
          map{|g, s, b| b.present? ? [nil, nil] : [g, s]}.transpose

      guess.each_with_index.map { |g, index|
        (i = secret.index(g)) && secret[i] = nil
        i.present? ? g : nil
      }
    end

    def hint(game, letter = nil)
      hint = letter.present? ? game.secret.split('').detect { |l| l == letter } : game.secret[rand(game.secret.length)]
      game.hints += 1
      game.save!

      hint
    end

    def stop!(game)
      raise 'Game has already finished. Please start a new game using _/create_ command.' if game.finished?

      game.finished!
      game.save!
    end

    def validate_game!(game)
      raise 'Game has finished. Please start a new game using _/create_ command.' if game.finished?
    end

    def validate_guess!(game, guess)
      # raise "Guess _#{guess}_ is not in dictionary, please try another word." unless Noun.find_by_noun(guess).present?
      raise "Your guess word _#{guess}_ has to be *#{game.secret.length}* letters long." if game.secret.length != guess.length
    end
  end

end
