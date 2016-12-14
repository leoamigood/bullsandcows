class GameService

  class << self
    def create(channel, secret, source)
      Game.create(
          channel: channel,
          secret: secret.noun,
          level: secret.level,
          dictionary: secret.dictionary,
          source: source
      )
    end

    def find_by_id!(game_id)
      game = Game.find_by_id(game_id)
      raise Errors::GameNotFoundException.new(
          "Failed to find game. Is game in progress? Game ID: #{game_id}"
      ) unless game.present?

      game
    end

    def find_by_channel!(channel)
      game = Game.where(channel: channel).last
      raise Errors::GameNotFoundException.new(
          "Failed to find game. Is game in progress? Channel ID: #{channel}"
      ) unless game.present?

      game
    end

    def find_games(options = {})
      Game.all.where(options.compact)
    end

    def guess(game, username, word, suggestion = false)
      guess = Guess.find_or_create_by(game_id: game.id, word: word) do |guess|
        guess.attempts = 0
        guess.username = username
        guess.suggestion = suggestion

        guess.update(match(word, game.secret))
      end

      guess.attempts += 1
      guess.save!

      guess.exact? ? game.finished! : game.running!
      guess
    end

    def match(guess, secret)
      bulls = bulls(guess.split(''), secret.split(''))
      cows = cows(guess.split(''), secret.split(''))

      return { word: guess, bulls: bulls.compact.count, cows: cows.compact.count, exact: guess == secret }
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
      hint = letter.present? ? detect_letter(game.secret, letter) : random_letter(game.secret)
      Hint.create!(game_id: game.id, letter: letter, hint: hint)

      hint
    end

    def stop!(game)
      raise 'Game has not started. Please start a new game using _/create_ command.' unless game.in_progress?

      game.aborted!
      game
    end

    def validate_game!(game)
      raise Errors::GameNotStartedException.new(game, 'Game has not started. Please start a new game using _/create_ command.') unless game.in_progress?
    end

    def validate_guess!(game, guess)
      # raise "Guess _#{guess}_ is not in dictionary, please try another word." unless Noun.find_by_noun(guess).present?
      raise "Your guess word _#{guess}_ has to be *#{game.secret.length}* letters long." if game.secret.length != guess.length
    end

    private

    def detect_letter(secret, letter)
      secret.split('').detect { |l| l == letter }
    end

    def random_letter(secret)
      secret[rand(secret.length)]
    end
  end

end
