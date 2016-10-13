class TelegramMessenger

  class << self
    def send_message(channel, text, markup = nil)
      Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
        bot.api.send_message(chat_id: channel, text: text, parse_mode: 'Markdown', reply_markup: markup)
      end
    end

    def answerCallbackQuery(channel, text = nil)
      Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
        bot.api.answerCallbackQuery(callback_query_id: channel, text: text)
      end
    end

    def welcome(channel)
      send_message(channel, 'Welcome to Bulls and Cows! Here be dragons! Well, the rules actually.')
    end

    def game_created(game)
      "Game created with *#{game.secret.length}* letters in the secret word."
    end

    def guess(guess)
      text = "Guess: _#{guess.word}_, *Bulls: #{guess.bulls}*, *Cows: #{guess.cows}*\n"
      text += "Congratulations! You guessed it with *#{guess.game.guesses.length}* tries" if guess.game.finished?

      text
    end

    def hint(letter)
      "Secret word has letter _#{letter}_ in it"
    end

    def tries(guesses)
      unless guesses.empty?
        text = guesses.each_with_index.map do |guess, i|
          "Try #{i + 1}: *#{guess.word}*, Bulls: *#{guess.bulls}*, Cows: *#{guess.cows}*"
        end
        text.join("\n")
      else
        self.no_guesses_submitted
      end
    end

    def best(guesses)
      unless guesses.empty?
        text = guesses.each_with_index.map do |guess, i|
          "Top #{i + 1}: *#{guess.word}*, Bulls: *#{guess.bulls}*, Cows: *#{guess.cows}*"
        end
        text.join("\n")
      else
        self.no_guesses_submitted
      end
    end

    def zeros(guesses)
      unless guesses.empty?
        text = guesses.each.map do |guess|
          "Zero letters in: *#{guess.word}*, Bulls: *#{guess.bulls}*, Cows: *#{guess.cows}*"
        end
        text.join("\n")
      else
        'There was no guesses with zero bulls and cows matches so far.'
      end
    end

    def ask_level(channel)
      kb = [
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Easy', callback_data: '/level easy'),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Medium', callback_data: '/level medium'),
          Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Hard', callback_data: '/level hard')
      ]
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

      send_message(channel, 'Select a game level:', markup)
    end

    def level(callbackQuery, level)
      answerCallbackQuery(callbackQuery.id, "Game level set to #{level}")
    end

    def game_stop(game)
      "You give up? Here is the secret word *#{game.secret}*"
    end

    def game_was_finished(game)
      'Game has already finished. Please start a new game using _/create_ command.'
    end

    def no_permissions_to_stop_game
      'You are NOT allowed to _/stop_ this game. Only _admin_ or _creator_ is'
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

    def unknown_command(message)
      "Nothing I can do with *#{message}*. For help try _/help_"
    end

    def new_game?
      'Go ahead and _/create_ a new game. For help try _/help_'
    end

    private

    def no_guesses_submitted
      'There was no guesses so far. Go ahead and submit one with _/guess <word>_'
    end
  end

end
