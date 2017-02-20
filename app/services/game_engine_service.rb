class GameEngineService

  class << self
    def create_by_word(channel, user_id, source, word)
      GameService.create(channel, user_id, Noun.new(noun: word), source)
    end

    def create_by_options(channel, user_id, source, options)
      secret = Noun.active.
          by_length(options[:length]).
          in_language(options[:language]).
          by_complexity(options[:language], options[:complexity]).
          order('RANDOM()').first

      raise Errors::GameCreateException.new('Unable to create game. Please try different parameters') unless secret.present?

      GameService.create(channel, user_id, secret, source)
    end

    def guess(game, user, word)
      GameService.validate_game!(game)
      GameService.validate_guess!(game, word)

      GameService.guess(game, user, word)
    end

    def hint(game, letter = nil)
      GameService.validate_game!(game)
      GameService.hint(game, letter)
    end

    def open(game, number)
      GameService.validate_game!(game)
      GameService.open(game, number)
    end

    def suggest(game, user, letters = nil)
      GameService.validate_game!(game)
      nouns = Noun.
          where(dictionary_id: game.dictionary_id).
          where('char_length(noun) = ?', game.secret.length).
          where("noun <> '#{game.secret}'")

      nouns = nouns.where("noun LIKE '%#{letters}%'") if letters.present?
      suggestion = nouns.order('RANDOM()').first

      GameService.guess(game, user, suggestion.noun.downcase, suggestion = true) if suggestion.present?
    end

    def tries(channel)
      game = GameService.find_by_channel!(channel)
      game.guesses
    end

    def best(channel, limit)
      game = GameService.find_by_channel!(channel)
      game.best(limit.try(:to_i))
    end

    def zero(channel)
      game = GameService.find_by_channel!(channel)
      game.zero
    end

    def language(language)
      lang = Dictionary.langs[language]
      raise "Language: #{language} is not available!" unless lang.present?

      lang
    end

    def settings(channel, attributes)
      setting = Setting.find_or_create_by!(channel: channel)

      setting.attributes = attributes
      setting.save!

      setting
    end
  end

end
