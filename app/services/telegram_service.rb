class TelegramService

  @@WELCOME_MSG = 'Welcome to Bulls and Cows! Here be dragons! Well, the rules actually.'

  def self.listen(bot, message)
    case message.text
      when /^\/start/
        bot.api.send_message(chat_id: message.chat.id, text: "#{@@WELCOME_MSG}")

      when /^\/secret ([[:alpha:]]+)/
        game = GameService.create("#{$1}")
        bot.api.send_message(chat_id: message.chat.id, text: "Game created with secret: <#{game.secret}>")

      when /^\/guess ([[:alpha:]]+)/
        begin
          game = GameService.find_game
          guess = GameService.guess(game, "#{$1}")
          bot.api.send_message(chat_id: message.chat.id, text: "Attempts: #{guess.game.guesses.length}, bulls: #{guess.bulls}, cows: #{guess.cows}")
          bot.api.send_message(chat_id: message.chat.id, text: 'Congratulations! You guessed it!') if game.finished?
        rescue => ex
          bot.logger.info("Error: #{ex.message}")

          bot.api.send_message(chat_id: message.chat.id, text: "Error: #{ex.message}")
        end

      when '/tries'
        game = GameService.find_game
        game.guesses.each do |guess|
          bot.api.send_message(chat_id: message.chat.id, text: "Guess: <#{guess.word}>, bulls: #{guess.bulls}, cows: #{guess.cows}")
        end

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
end