class TelegramService

  @@WELCOME_MSG = 'Welcome to Bulls and Cows! Here be dragons! Well, the rules actually.'

  def self.listen(bot, message)
    case message.text
      when /^\/start/
        bot.api.send_message(chat_id: message.chat.id, text: "#{@@WELCOME_MSG}")

      when /^\/secret ([[:alpha:]]+)/
        game = GameService.create(message.chat.id, "#{$1}", :telegram)
        bot.api.send_message(chat_id: message.chat.id, text: 'Game created!')

      when /^\/secret ([[:digit:]])/
        secret = Noun.where('length(noun) = ?', $1).order('RAND()').first!.noun
        game = GameService.create(message.chat.id, "#{secret}", :telegram)
        bot.api.send_message(chat_id: message.chat.id, text: "Game created! #{game.secret.length} in the secret word.")

      when /^\/secret [[:digit]]/
        secret = Noun.offset(rand(Noun.count)).first!.noun
        game = GameService.create(message.chat.id, "#{secret}", :telegram)
        bot.api.send_message(chat_id: message.chat.id, text: "Game created! Secret word contains #{game.secret.length} letters.")

      when /^\/guess ([[:alpha:]]+)/
        guess(bot, message, $1)

      when '/tries'
        list_attempts(bot, message)

      when '/stop'
        bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")

      when '/help'
        bot.api.send_message(chat_id: message.chat.id, text: 'Use /secret <word> to create a game')
        bot.api.send_message(chat_id: message.chat.id, text: 'Use /guess <word> to guess a secret word')
        bot.api.send_message(chat_id: message.chat.id, text: 'Use /tries to show previous attempts')

      else
        bot.api.send_message(chat_id: message.chat.id, text: "Nothing i can do with #{message}. For help type /help")
    end
  end

  def self.list_attempts(bot, message)
    game = Game.where(channel: message.chat.id).last
    raise "Failed to find the game. Is game started for telegram message chat ID: #{message.chat.id}" unless game.present?

    game.guesses.each do |guess|
      bot.api.send_message(chat_id: message.chat.id, text: "Guess: <#{guess.word}>, bulls: #{guess.bulls}, cows: #{guess.cows}")
    end
  end

  def self.guess(bot, message, guess)
    begin
      game = Game.where(channel: message.chat.id).last
      raise "Failed to find the game. Is game started for telegram message chat ID: #{message.chat.id}" unless game.present?

      guess = GameService.guess(game, "#{guess}")
      bot.api.send_message(chat_id: message.chat.id, text: "Attempts: #{guess.game.guesses.length}, bulls: #{guess.bulls}, cows: #{guess.cows}")
      bot.api.send_message(chat_id: message.chat.id, text: 'Congratulations! You guessed it!') if game.finished?
    rescue => ex
      bot.logger.info("Error: #{ex.message}")

      bot.api.send_message(chat_id: message.chat.id, text: "Error: #{ex.message}")
    end
  end
end