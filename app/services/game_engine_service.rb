class GameEngineService

  class << self
    def create(channel, source, complexity = nil)
      levels = level(complexity)

      nouns = Noun.active
      nouns = nouns.where(:level => levels) if levels.present?
      secret = nouns.offset(rand(nouns.count)).first!

      GameService.create(channel, secret, source)
    end

    def create_by_word(channel, word, source)
      GameService.create(channel, Noun.new(noun: word), source)
    end

    def create_by_number(channel, number, source, complexity = nil)
      levels = level(complexity)

      nouns = Noun.active
      nouns = nouns.where(:level => levels) if levels.present?
      secret = nouns.where('char_length(noun) = ?', number).order('RANDOM()').first
      raise "Unable to create a game with #{number} letters word. Please try different amount." unless secret.present?

      GameService.create(channel, secret, source)
    end

    def guess(channel, username, word)
      game = GameService.find!(channel)

      GameService.is_running?(game)
      GameService.validate_guess!(game, word)

      GameService.guess(game, username, word)
    end

    def hint(channel)
      game = GameService.find!(channel)

      GameService.is_running?(game)
      GameService.hint(game)
    end

    def tries(channel)
      game = GameService.find!(channel)
      game.guesses
    end

    def best(channel, limit = 8)
      game = GameService.find!(channel)
      game.guesses.sort.first(limit.to_i)
    end

    def zero(channel)
      game = GameService.find!(channel)
      game.guesses.where(bulls: 0, cows: 0)
    end

    def level(complexity)
      case complexity
        when 'easy'
          [1, 2]
        when 'medium'
          [3, 4]
        when 'hard'
          [5]
        else
          nil
      end
    end

    def complexity(channel)
      Setting.find_by_channel(channel).try(:complexity)
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

    def stop(channel)
      game = GameService.find!(channel)
      GameService.stop!(game)

      game
    end
  end

end
