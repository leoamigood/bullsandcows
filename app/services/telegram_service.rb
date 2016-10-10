class TelegramService

  class << self
    def create(channel, levels = nil)
      nouns = Noun.active
      nouns = nouns.where(:level => levels) if levels.present?
      secret = nouns.offset(rand(nouns.count)).first!

      GameService.create(channel, secret, :telegram)
    end

    def create_by_word(channel, word)
      GameService.create(channel, Noun.new(noun: word), :telegram)
    end

    def create_by_number(channel, number, levels = nil)
      nouns = Noun.active
      nouns = nouns.where(:level => levels) if levels.present?
      secret = nouns.where('char_length(noun) = ?', number).order('RANDOM()').first
      raise "Unable to create a game with #{number} letters word. Please try different amount." unless secret.present?

      GameService.create(channel, secret, :telegram)
    end

    def guess(channel, username, word)
      game = Game.where(channel: channel).last
      raise "Failed to find the game. Is game started for telegram message chat ID: #{channel}" unless game.present?

      GameService.validate_game!(game)
      GameService.validate_guess!(game, word)

      GameService.guess(game, username, word)
    end

    def hint(channel)
      game = Game.where(channel: channel).last
      raise "Failed to find the game. Is game started for telegram message chat ID: #{channel}" unless game.present?

      GameService.validate_game!(game)
      GameService.hint(game)
    end

    def tries(channel)
      game = Game.where(channel: channel).last
      raise "Failed to find the game. Is game started for telegram message channel: #{channel}" unless game.present?

      game.guesses
    end

    def best(channel, limit = 8)
      game = Game.where(channel: channel).last
      raise "Failed to find the game. Is game started for telegram message channel: #{channel}" unless game.present?

      game.guesses.sort.first(limit.to_i)
    end

    def zeros(channel)
      game = Game.where(channel: channel).last
      raise "Failed to find the game. Is game started for telegram message channel: #{channel}" unless game.present?

      game.guesses.where(bulls: 0, cows: 0)
    end

    def level(level)
      case level
        when 'easy'
          [1, 2]
        when 'medium'
          [3, 4]
        when 'hard'
          [5, 6]
      end
    end

    def stop_permitted?(message)
      Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
        member = bot.api.getChatMember({chat_id: message.chat.id, user_id: message.from.id})
        status = member['result']['status']

        message.chat.type == 'group' ? status == 'creator' || status == 'administrator' : status == 'member'
      end
    end

    def stop(channel)
      game = Game.where(channel: channel).last
      raise "Failed to find the game. Is game started for telegram message chat ID: #{channel}" unless game.present?

      GameService.validate_game!(game)

      game.finished!
      game.save!

      game
    end
  end

end
