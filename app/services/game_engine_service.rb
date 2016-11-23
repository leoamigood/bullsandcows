class GameEngineService

  class << self
    def create_by_word(channel, word, source)
      GameService.create(channel, Noun.new(noun: word), source)
    end

    def create_by_number(channel, number, source)
      settings = Setting.find_by_channel(channel) || Setting.new

      levels = get_level_by_complexity(settings.complexity)
      language = get_language_or_default(settings.language)

      nouns = Noun.active.in_language(language)
      nouns = nouns.where(:level => levels) if levels.present?
      raise "No words found in dictionaries with complexity: #{settings.complexity} and language: #{settings.language} " unless nouns.present?

      secret = nouns.where('char_length(noun) = ?', number).order('RANDOM()').first
      raise "Unable to create a game with #{number} letters word. Please try different amount." unless secret.present?

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
      suggestion = Noun.
          where(dictionary_id: game.dictionary_id).
          where('char_length(noun) = ?', game.secret.length).
          where("noun LIKE '%#{letters}%'").
          where("noun <> '#{game.secret}'").
          order('RANDOM()').first

      GameService.guess(game, username, suggestion.noun, suggestion = true) if suggestion.present?
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

    def get_language_or_default(language = nil)
      lang = Dictionary.langs[language || :RU]
      raise "Language: #{language} is not available!" unless lang.present?

      lang
    end

    def get_level_by_complexity(complexity)
      case complexity
        when 'easy'
          [4, 5]
        when 'medium'
          [2, 3]
        when 'hard'
          [1, 2, 3]
        else
          nil
      end
    end

    def settings(channel, attributes)
      setting = Setting.find_or_create_by!(channel: channel)

      setting.attributes = attributes
      setting.save!

      setting
    end

    def stop_permitted?(message)
      Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
        member = bot.api.getChatMember({chat_id: message.chat.id, user_id: message.from.id})
        status = member['result']['status']

        message.chat.type == 'group' ? status == 'creator' || status == 'administrator' : status == 'member'
      end
    end
  end

end
