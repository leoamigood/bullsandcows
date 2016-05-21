class TelegramService

  @@WELCOME_MSG = 'Welcome to Bulls and Cows! Here be dragons! Well, the rules actually.'

  def self.listen(bot, message)
    begin
      case message.text.downcase
        when /^\/start/
          bot.api.send_message(chat_id: message.chat.id, text: "#{@@WELCOME_MSG}")

        when /^\/secret ([[:alpha:]]+)/
          game = GameService.create(message.chat.id, "#{$1}", :telegram)
          bot.api.send_message(chat_id: message.chat.id, text: 'Game created!')

        when /^\/secret ([[:digit:]])/
          secret = Noun.where('length(noun) = ?', $1).order('RAND()').first!.noun
          game = GameService.create(message.chat.id, secret, :telegram)
          bot.api.send_message(chat_id: message.chat.id, text: "Game created with *#{game.secret.length}* letters in the secret word.", parse_mode: 'Markdown')

        when /^\/secret/
          secret = Noun.offset(rand(Noun.count)).first!.noun
          game = GameService.create(message.chat.id, secret, :telegram)
          bot.api.send_message(chat_id: message.chat.id, text: "Game created with *#{game.secret.length}* letters in the secret word.", parse_mode: 'Markdown')

        when /^\/guess ([[:alpha:]]+)/
          guess(bot, message, $1)

        when '/tries'
          list_attempts(bot, message)

        when '/stop'
          bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")

        when '/help'
          bot.api.send_message(chat_id: message.chat.id, text: 'Use _/secret_ to create a game', parse_mode: 'Markdown')
          bot.api.send_message(chat_id: message.chat.id, text: 'Use _/guess <word>_ to guess the secret word', parse_mode: 'Markdown')
          bot.api.send_message(chat_id: message.chat.id, text: 'Use _/tries_ to show previous attempts', parse_mode: 'Markdown')

        else
          bot.api.send_message(chat_id: message.chat.id, text: "Nothing i can do with *#{message}*. For help try _/help_", parse_mode: 'Markdown')
      end
    rescue => ex
      bot.logger.info("Error: #{ex.message}")

      bot.api.send_message(chat_id: message.chat.id, text: "Error: #{ex.message}", parse_mode: 'Markdown')
    end
  end

  def self.list_attempts(bot, message)
    game = Game.where(channel: message.chat.id).last
    raise "Failed to find the game. Is game started for telegram message chat ID: #{message.chat.id}" unless game.present?

    game.guesses.each do |guess|
      bot.api.send_message(chat_id: message.chat.id, text: "Guess: *#{guess.word}*, Bulls: *#{guess.bulls}*, Cows: *#{guess.cows}*", parse_mode: 'Markdown')
    end
  end

  def self.guess(bot, message, word)
    game = Game.where(channel: message.chat.id).last
    raise "Failed to find the game. Is game started for telegram message chat ID: #{message.chat.id}" unless game.present?

    GameService.validate!(game, word)

    guess = GameService.guess(game, word)
    bot.api.send_message(chat_id: message.chat.id, text: "Guess: _#{word}_, *Bulls: #{guess.bulls}*, *Cows: #{guess.cows}*", parse_mode: 'Markdown')
    bot.api.send_message(chat_id: message.chat.id, text: "Congratulations! You guessed it with *#{guess.game.guesses.length}* tries", parse_mode: 'Markdown') if game.finished?
  end
end