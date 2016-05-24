class TelegramService

  @@WELCOME_MSG = 'Welcome to Bulls and Cows! Here be dragons! Well, the rules actually.'

  def self.listen(bot, message)
    begin
      case message.text.downcase
        when /^\/start/
          bot.api.send_message(chat_id: message.chat.id, text: "#{@@WELCOME_MSG}")

        when /^\/create ([[:alpha:]]+)/
          secret = Noun.find_by_noun($1)
          raise "Word #{$1} not found in the dictionary. Please try different secret word." unless secret.present?

          GameService.create(message.chat.id, "#{secret.noun}", :telegram)
          bot.api.send_message(chat_id: message.chat.id, text: 'Game created!')

        when /^\/create ([[:digit:]]+)/
          secret = Noun.where('char_length(noun) = ?', $1).order('RAND()').first
          raise "Unable to create a game with #{$1} letters word. Please try different amount." unless secret.present?

          game = GameService.create(message.chat.id, secret.noun, :telegram)
          bot.api.send_message(chat_id: message.chat.id, text: "Game created with *#{game.secret.length}* letters in the secret word.", parse_mode: 'Markdown')

        when /^\/create$/
          secret = Noun.offset(rand(Noun.count)).first!.noun
          game = GameService.create(message.chat.id, secret, :telegram)
          bot.api.send_message(chat_id: message.chat.id, text: "Game created with *#{game.secret.length}* letters in the secret word.", parse_mode: 'Markdown')

        when /^\/guess ([[:alpha:]]+)/
          guess(bot, message.chat.id, $1)

        when /^\/tries$/
          tries = list_attempts(message.chat.id)
          text = tries.each_with_index.map do |guess, i|
            "Attempt #{i + 1}: *#{guess.word}*, Bulls: *#{guess.bulls}*, Cows: *#{guess.cows}*"
            # bot.api.send_message(chat_id: message.chat.id, text: "Attempt #{i + 1}: *#{guess.word}*, Bulls: *#{guess.bulls}*, Cows: *#{guess.cows}*", parse_mode: 'Markdown')
          end
          bot.api.send_message(chat_id: message.chat.id, text: text.join("\n"), parse_mode: 'Markdown')

        when '/stop$'
          bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")

        when '/help$'
          lines = ['Use _/create_ to create a game', 'Use _/guess <word>_ to guess the secret word', 'Use _/tries_ to show previous attempts']
          bot.api.send_message(chat_id: message.chat.id, text: lines.join("\n"), parse_mode: 'Markdown')

        else
          game = Game.where(channel: message.chat.id).last
          if game.present?
            unless game.finished?
              guess(bot, message.chat.id, message.text.downcase)
            else
              bot.api.send_message(chat_id: message.chat.id, text: 'Go ahead and _/create_ a new game. For help try _/help_', parse_mode: 'Markdown')
            end
          else
            bot.api.send_message(chat_id: message.chat.id, text: "Nothing I can do with *#{message}*. For help try _/help_", parse_mode: 'Markdown')
          end
      end
    rescue => ex
      begin
        bot.logger.info("Error: #{ex.message}")

        bot.api.send_message(chat_id: message.chat.id, text: "Error: #{ex.message}", parse_mode: 'Markdown')
      rescue => internal
        bot.logger.info("Error: #{internal.message}")
      end
    end
  end

  def self.list_attempts(channel)
    game = Game.where(channel: channel).last
    raise "Failed to find the game. Is game started for telegram message chat ID: #{message.chat.id}" unless game.present?

    game.guesses
  end

  def self.guess(bot, channel, word)
    game = Game.where(channel: channel).last
    raise "Failed to find the game. Is game started for telegram message chat ID: #{channel}" unless game.present?

    GameService.validate!(game, word)

    guess = GameService.guess(game, word)
    bot.api.send_message(chat_id: channel, text: "Guess: _#{word}_, *Bulls: #{guess.bulls}*, *Cows: #{guess.cows}*", parse_mode: 'Markdown')
    bot.api.send_message(chat_id: channel, text: "Congratulations! You guessed it with *#{guess.game.guesses.length}* tries", parse_mode: 'Markdown') if game.finished?
  end
end