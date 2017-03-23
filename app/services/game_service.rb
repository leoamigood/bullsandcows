class GameService

  class << self
    def create(realm, secret)
      if (in_progress?(realm.channel))
        raise Errors::GameCreateException.new(
            'Cannot start new game. Finish or stop current game using _/stop_ command.',
            recent_game(realm.channel)
        )
      end

      Game.create(
          channel: realm.channel,
          user_id: realm.user_id,
          secret: secret.noun,
          level: secret.level,
          dictionary: secret.dictionary,
          source: realm.source
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
      game = recent_game(channel)

      raise Errors::GameNotFoundException.new(
          "Failed to find game. Is game in progress? Channel ID: #{channel}"
      ) unless game.present?

      game
    end

    def find_games(options = {})
      Game.all.where(options.compact)
    end

    def guess(game, user, word, suggestion = false)
      sanitized = sanitize(word)
      guess = Guess.find_or_create_by(game_id: game.id, word: sanitized) do |guess|
        guess.attempts = 0
        guess.user_id = user.id
        guess.username = user.name
        guess.suggestion = suggestion

        guess.update(match(sanitized, game.secret))
      end

      guess.attempts += 1
      guess.save!

      guess.exact? ? game.finished! : game.running!
      guess
    end

    def sanitize(word)
      downcased = word.mb_chars.downcase
      downcased.tr('ё'.force_encoding('utf-8'),'е'.force_encoding('utf-8')).to_s
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

    def open(game, number)
      hint = game.secret[number - 1]
      Hint.create!(game_id: game.id, hint: hint)

      hint
    end

    def stop!(game)
      game.aborted!
      game
    end

    def validate_guess!(game, guess)
      raise "Your guess word _#{guess}_ has to be *#{game.secret.length}* letters long." if game.secret.length != guess.length
    end

    def recent_game(channel)
      Game.where(channel: channel).last
    end

    def in_progress?(channel)
      !!recent_game(channel).try(:in_progress?)
    end

    private

    def sanitize(word)
      word.downcase.gsub('ё','е')
    end

    def detect_letter(secret, letter)
      secret.split('').detect { |l| l == letter }
    end

    def random_letter(secret)
      secret[rand(secret.length)]
    end
  end

end
