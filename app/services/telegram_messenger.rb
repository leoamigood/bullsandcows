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

    def ask_language(channel)
      kb = %w(English Russian).reduce([]) { |kb, lang|
        kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: lang, callback_data: "/lang #{lang[0..1].upcase}")
      }
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

      send_message(channel, 'Select game language:', markup)
    end

    def language(lang)
      case lang
        when Dictionary.langs[:RU]
          language = 'Russian'
        when Dictionary.langs[:EN]
          language = 'English'
        else
          language = 'Unknown'
      end
      "Language was set to #{language}"
    end

    def ask_create_game(channel)
      kb = (4..8).reduce([]) { |kb, n|
        kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: n, callback_data: "/create #{n}")
      }
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

      send_message(channel, 'How many letters would it be?', markup)
    end

    def game_created(game)
      "Game created with #{game.secret.length} letters in the secret word."
    end

    def guess(guess)
      text = "Guess: _#{guess.word}_, *Bulls: #{guess.bulls}*, *Cows: #{guess.cows}*\n"
      text += "Congratulations! You guessed it with *#{guess.game.guesses.length}* tries" if guess.exact?

      text
    end

    def hint(letter)
      "Secret word has letter _#{letter}_ in it"
    end

    def no_hint(letter)
      "Secret word has NO letter _#{letter}_ in it"
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

    def zero(guesses)
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
      kb = %w(easy medium hard).reduce([]) { |kb, level|
        kb << Telegram::Bot::Types::InlineKeyboardButton.new(text: level, callback_data: "/level #{level}")
      }
      markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb)

      send_message(channel, 'Select game level:', markup)
    end

    def level(level)
      "Game level was set to #{level}"
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

      # lang   - Use /lang to set secret word language
      # create - Use /create [word]|[number] to create a game
      # guess  - Use /guess <word> to place a guess for the secret
      # tries  - Use /tries to show previous guess attempts
      # best   - Use /best [number] to see top guesses
      # hint   - Use /hint to reveal a random letter in a secret
      # zero   - Use /zero to see guesses with zero matches
      # level  - Use /level to set game complexity level
      # stop   - Use /stop to abort the game and show secret

      lines = [
          'Here is the list of available commands:',
          'Use _/lang_ to set secret word language',
          'Use _/create [word]|[number]_ to create a game',
          'Use _/guess <word>_ to place a guess for the secret',
          'Use _/tries_ to show previous guess attempts',
          'Use _/best [number]_ to see top guesses',
          'Use _/hint_ to reveal a random letter in a secret',
          'Use _/zero_ to see guesses with zero matches',
          'Use _/level_ to set game complexity level',
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