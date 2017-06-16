module Telegram
  class TelegramMessenger

    class << self
      def send_message(channel, text, markup = nil, parse_mode = 'Markdown')
        Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
          bot.api.send_message(chat_id: channel, text: text, reply_markup: markup, parse_mode: parse_mode)
        end
      end

      def answerCallbackQuery(channel, text = nil)
        Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
          bot.api.answerCallbackQuery(callback_query_id: channel, text: text)
        end
      end

      def answerInlineQuery(inline_query_id, markup, defaults = {})
        Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
          bot.api.answerInlineQuery(defaults.merge(inline_query_id: inline_query_id, results: markup, cache_time: 0))
        end
      end

      def getChatMember(channel, user_id)
        Telegram::Bot::Client.run(TELEGRAM_TOKEN) do |bot|
          bot.api.getChatMember(chat_id: channel, user_id: user_id)
        end
      end

      def welcome(channel, prologue = nil)
        case prologue
          when Telegram::Action::Options::HOWTO
            send_message(channel, rules)
          else
            send_message(channel, 'Welcome to Bulls and Cows! Use /rules command to learn how to play.')
        end
      end

      def howto(id)
        options = { switch_pm_text: 'How to use this bot', switch_pm_parameter: Telegram::Action::Options::HOWTO }
        TelegramMessenger.answerInlineQuery(id, [], options)
      end

      def ask_language(channel)
        kb = %w(English Russian Italiano Deutsch French).each_with_object([]) { |lang, memo|
          memo << Telegram::Bot::Types::InlineKeyboardButton.new(text: lang, callback_data: "/lang #{lang[0..1].upcase}")
        }
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: [kb])

        send_message(channel, 'Select game language:', markup)
      end

      def language(lang)
        case lang
          when Dictionary.langs[:RU]
            language = 'Русский'
          when Dictionary.langs[:EN]
            language = 'English'
          when Dictionary.langs[:IT]
            language = 'Italiano'
          when Dictionary.langs[:DE]
            language = 'Deutsch'
          when Dictionary.langs[:FR]
            language = 'French'
          else
            language = 'Unknown'
        end
        "Language was set to #{language}."
      end

      def ask_length(channel)
        kb = (4..8).each_with_object([]) { |n, memo|
          memo << Telegram::Bot::Types::InlineKeyboardButton.new(text: n, callback_data: "/create #{n}")
        }
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: [kb])

        send_message(channel, 'How many letters will it be?', markup)
      end

      def game_created(game)
        message = "Game created: *#{game.secret.length}* letters."
        message += " Language: *#{game.dictionary.lang}*." if game.dictionary.present?
        message += " Points: *#{game.score.worth}*." if game.score.present?

        message + "\nGo ahead and submit your guess word."
      end

      def guess(guess)
        text = "Guess #{guess.game.guesses_count}: _#{guess.word}_, *Bulls: #{guess.bulls}*, *Cows: #{guess.cows}*.\n"
        text += TelegramMessenger.finish(guess.game) if guess.exact?

        text
      end

      def query(id, words)
        markup = words.map do |word|
          Telegram::Bot::Types::InlineQueryResultArticle.new(
              id: "#{word.noun} #{word.dictionary.lang}",
              title: 'Create new game using secret word:',
              description: "#{word.noun} (#{word.dictionary.lang})",
              input_message_content: Telegram::Bot::Types::InputTextMessageContent.new(message_text: '/create')
          )
        end

        TelegramMessenger.answerInlineQuery(id, markup)
      end

      def finish(game)
        text = "Congratulations! You guessed it with *#{game.guesses.length}* tries.\n"

        if game.score.present?
          text += "You earned *#{game.score.worth}* points."
          text += " Bonus: *#{game.score.bonus}* points." if game.score.bonus > 0
          text += " Penalty: *-#{game.score.penalty}* points." if game.score.penalty > 0
          text += "\nTotal score: *#{game.score.total}* points."
        end

        text
      end

      def hint(letter)
        "Secret word has letter *#{letter}* in it."
      end

      def no_hint(letter)
        "Secret word has NO letter *#{letter}* in it."
      end

      def suggestion(guess)
        "Suggestion: _#{guess.word}_, *Bulls: #{guess.bulls}*, *Cows: #{guess.cows}*."
      end

      def no_suggestions(letters)
        "Could not find any suggestions based on provided word letters _#{letters}_."
      end

      def tries(guesses)
        unless guesses.empty?
          text = guesses.each_with_index.map do |guess, i|
            "Try #{i + 1}: *#{guess.word}*, Bulls: *#{guess.bulls}*, Cows: *#{guess.cows}*."
          end
          text.join("\n")
        else
          self.no_guesses_submitted
        end
      end

      def best(guesses)
        unless guesses.empty?
          text = guesses.each_with_index.map do |guess, i|
            "Top #{i + 1}: *#{guess.word}*, Bulls: *#{guess.bulls}*, Cows: *#{guess.cows}*."
          end
          text.join("\n")
        else
          self.no_guesses_submitted
        end
      end

      def zero(guesses)
        unless guesses.empty?
          text = guesses.each.map do |guess|
            "Zero letters in: *#{guess.word}*, Bulls: *#{guess.bulls}*, Cows: *#{guess.cows}*."
          end
          text.join("\n")
        else
          'There was no guesses with zero bulls and cows matches so far.'
        end
      end

      def ask_level(channel)
        kb = %w(easy medium hard).each_with_object([]) { |level, memo|
          memo << Telegram::Bot::Types::InlineKeyboardButton.new(text: level, callback_data: "/level #{level}")
        }
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: [kb])

        send_message(channel, 'Select game level:', markup)
      end

      def level(level)
        "Game level was set to #{level}."
      end

      def game_stop(game)
        "You give up? Here is the secret word *#{game.secret}*."
      end

      def top_scores(scores)
        scores.empty? ? no_scores : "Total scores:\n" + scores(scores).join("\n")
      end

      def top_trends(scores, since)
        scores.empty? ? no_scores : "Top players of the #{since}:\n" + scores(scores).join("\n")
      end

      def no_scores
        'No scores yet. Start a new game using <i>/start</i> command.'
      end

      def scores(scores)
        scores.each.with_index(1).map { |score, i|
          name = "<b>#{[score['first_name'], score['last_name']].compact.join(' ')}</b>, "
          user = "User: <i>#{score['username']}</i>, " if score['username'].present?
          total = "Score: <b>#{ActiveSupport::NumberHelper.number_to_human(score['total_score'])}</b>"

          "#{i}: #{name}#{user}#{total}"
        }
      end

      def rules
        '[Bulls & Cows Game Rules](https://en.wikipedia.org/wiki/Bulls_and_Cows)'
      end

      def faq
        lines = %w(/rules /help)
        Telegram::Bot::Types::ReplyKeyboardMarkup.new(
            keyboard: lines.each_with_object([]) { |line, memo|
              memo << [Telegram::Bot::Types::KeyboardButton.new(text: line)]
            },
            one_time_keyboard: true,
            selective: true
        )
      end

      def help
        # start   - Use /start to start the game bot
        # best    - Use /best [number] to show best guesses
        # level   - Use /level to set game complexity level
        # lang    - Use /lang to set secret word language
        # create  - Use /create [word]|[number] to create a game
        # guess   - Use [/guess] <word> to place a guess for the secret
        # tries   - Use /tries to show previous guess attempts
        # zero    - Use /zero to show guesses with zero matches
        # hint    - Use /hint to reveal a random letter in a secret
        # suggest - Use /suggest [letters] for bot to suggest a word
        # stop    - Use /stop to abort the game and show secret
        # score   - Use /score to show total scores
        # trend   - Use /trend _[day|week|month]_ to show top players
        # rules   - Use /rules to see the game rules
        # faq     - Usr /faq to show game FAQ
        # help    - Usr /help to show this help

        lines = [
            'Here is the list of available commands:',
            '/start to start the game bot',
            '/best _[number]_ to show best guesses',
            '/level to set game complexity level',
            '/lang to set secret word language',
            '/create _[word|number]_ to create a game',
            '/guess _<word>_ to place a guess for the secret',
            '/tries to show previous guess attempts',
            '/zero to show guesses with zero matches',
            '/hint _[letter|number]_ to reveal a letter in a secret',
            '/suggest _[letters]_ for bot to suggest a word',
            '/stop to abort the game and show secret',
            '/score to show total scores',
            '/trend _[day|week|month]_ to show top players',
            '/rules to see the game rules',
            '/faq to show game FAQ',
            '/help to show this help'
        ]
        lines.join("\n")
      end

      def unknown_command(message)
        "Nothing I can do with *#{message}*. For help try _/help_."
      end

      def new_game_ask
        'Go ahead and _/create_ a new game. For help try _/help_.'
      end

      def no_guesses_submitted
        'There was no guesses so far. Go ahead and submit one with _/guess <word>_.'
      end
    end

  end
end
