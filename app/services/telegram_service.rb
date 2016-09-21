class TelegramService

  @@WELCOME_MSG = 'Welcome to Bulls and Cows! Here be dragons! Well, the rules actually.'

  class << self
    def start
      @@WELCOME_MSG
    end

    def create(channel)
      secret = Noun.offset(rand(Noun.count)).first!.noun

      game = GameService.create(channel, secret, :telegram)
      "Game created with *#{game.secret.length}* letters in the secret word."
    end

    def create_by_word(channel, word)
      game = GameService.create(channel, word, :telegram)
      "Game created with *#{game.secret.length}* letters in the secret word."
    end

    def create_by_number(channel, number)
      secret = Noun.where('char_length(noun) = ?', number).order('RANDOM()').first
      raise "Unable to create a game with #{number} letters word. Please try different amount." unless secret.present?

      game = GameService.create(channel, secret.noun, :telegram)
      "Game created with *#{game.secret.length}* letters in the secret word."
    end

    def guess(channel, username, word)
      game = Game.where(channel: channel).last
      raise "Failed to find the game. Is game started for telegram message chat ID: #{channel}" unless game.present?

      GameService.validate_game!(game)
      GameService.validate_guess!(game, word)

      guess = GameService.guess(game, username, word)

      text = "Guess: _#{word}_, *Bulls: #{guess.bulls}*, *Cows: #{guess.cows}*"
      text += "\nCongratulations! You guessed it with *#{guess.game.guesses.length}* tries" if game.finished?

      text
    end

    def hint(channel)
      game = Game.where(channel: channel).last
      raise "Failed to find the game. Is game started for telegram message chat ID: #{channel}" unless game.present?

      GameService.validate_game!(game)
      letter = GameService.hint(game)

      "Secret word has letter _#{letter}_ in it"
    end

    def tries(channel)
      game = Game.where(channel: channel).last
      raise "Failed to find the game. Is game started for telegram message channel: #{channel}" unless game.present?

      tries = game.guesses
      unless tries.empty?
        text = tries.each_with_index.map do |guess, i|
          "Try #{i + 1}: *#{guess.word}*, Bulls: *#{guess.bulls}*, Cows: *#{guess.cows}*"
        end
        text.join("\n")
      else
        'There was no guesses so far. Go ahead and submit one with _/guess <word>_'
      end
    end

    def best(channel, limit = 5)
      game = Game.where(channel: channel).last
      raise "Failed to find the game. Is game started for telegram message channel: #{channel}" unless game.present?

      guesses = game.guesses.sort.last(limit.to_i).reverse

      unless guesses.empty?
        text = guesses.each_with_index.map do |guess, i|
          "Top #{i + 1}: *#{guess.word}*, Bulls: *#{guess.bulls}*, Cows: *#{guess.cows}*"
        end
        text.join("\n")
      else
        'There was no guesses so far. Go ahead and submit one with _/guess <word>_'
      end
    end

    def stop_permitted(message)
      token = ENV['TELEGRAM_API_TOKEN']
      Telegram::Bot::Client.run(token) do |bot|
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

      "You give up? Here is the secret word *#{game.secret}*"
    end

    def help
      lines = [
          'Here is the list of available commands:',
          'Use _/create [word]|[number]_ to create a game',
          'Use _/guess <word>_ to place a guess for the secret',
          'Use _/tries_ to show previous guess attempts',
          'Use _/best [number]_ to see top guesses',
          'Use _/hint_ to reveal a random letter in a secret',
          'Use _/stop_ to abort the game and show secret'
      ]
      lines.join("\n")
    end
  end

end