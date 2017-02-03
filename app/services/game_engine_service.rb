class GameEngineService

  class << self
    def create_by_word(channel, source, word)
      GameService.create(channel, Noun.new(noun: word), source)
    end

    def create_by_options(channel, source, options)
      secret = Noun.active.
          by_length(options[:length]).
          in_language(options[:language]).
          by_complexity(options[:language], options[:complexity]).
          order('RANDOM()').first

      raise Errors::GameCreateException.new('Unable to create game. Please try different parameters') unless secret.present?

      GameService.create(channel, secret, source)
    end

    def guess(game, username, word)
      GameService.validate_game!(game)
      GameService.validate_guess!(game, word)

      GameService.guess(game, username, word)
    end

    def hint(game, letter = nil)
      GameService.validate_game!(game)
      GameService.hint(game, letter)
    end

    def suggest(game, username, letters)
      GameService.validate_game!(game)
      suggestion = Noun.
          where(dictionary_id: game.dictionary_id).
          where('char_length(noun) = ?', game.secret.length).
          where("noun LIKE '%#{letters}%'").
          where("noun <> '#{game.secret}'").
          order('RANDOM()').first

      GameService.guess(game, username, suggestion.noun.downcase, suggestion = true) if suggestion.present?
    end

    def tries(channel)
      game = GameService.find_by_channel!(channel)
      game.guesses
    end

    def best(channel, limit = 8)
      game = GameService.find_by_channel!(channel)
      game.best(limit)
    end

    def zero(channel, limit = 5)
      game = GameService.find_by_channel!(channel)
      game.zero(limit)
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
