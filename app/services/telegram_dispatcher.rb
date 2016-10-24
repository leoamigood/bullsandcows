class TelegramDispatcher

  class CommandRegExp
    BOT_REGEXP = '(?:@BullsAndCowsWordsBot)?'

    BEST         = /^#{Command::BEST}#{BOT_REGEXP}$/i
    BEST_DIGIT   = /^#{Command::BEST}#{BOT_REGEXP}\s+(?<best>[[:digit:]]+)$/i
    CREATE       = /^#{Command::CREATE}#{BOT_REGEXP}$/i
    CREATE_ALPHA = /^#{Command::CREATE}#{BOT_REGEXP}\s+(?<secret>[[:alpha:]]+)$/i
    CREATE_DIGIT = /^#{Command::CREATE}#{BOT_REGEXP}\s+(?<number>[[:digit:]]+)$/i
    GUESS        = /^#{Command::GUESS}#{BOT_REGEXP}\s+(?<guess>[[:alpha:]]+)$/i
    HELP         = /^#{Command::HELP}#{BOT_REGEXP}$/i
    HINT         = /^#{Command::HINT}#{BOT_REGEXP}$/i
    HINT_ALPHA   = /^#{Command::HINT}#{BOT_REGEXP}\s+(?<letter>[[:alpha:]])$/i
    LANG         = /^#{Command::LANG}#{BOT_REGEXP}$/i
    LANG_ALPHA   = /^#{Command::LANG}#{BOT_REGEXP}\s+(?<language>[[:alpha:]]+)$/i
    LEVEL        = /^#{Command::LEVEL}#{BOT_REGEXP}$/i
    LEVEL_ALPHA  = /^#{Command::LEVEL}#{BOT_REGEXP}\s+(?<level>[[:alpha:]]+)$/i
    START        = /^#{Command::START}#{BOT_REGEXP}$/i
    STOP         = /^#{Command::STOP}#{BOT_REGEXP}$/i
    TRIES        = /^#{Command::TRIES}#{BOT_REGEXP}$/i
    ZERO         = /^#{Command::ZERO}#{BOT_REGEXP}$/i
  end

  class CommandQueue
    @queue = []

    class << self
      def push(&block)
        @queue.push(block)
      end

      def pop
        @queue.pop
      end

      def execute
        shift.try(:call)
      end

      def shift
        @queue.shift
      end

      def size
        @queue.size
      end

      def clear
        @queue.clear
      end

      def empty?
        @queue.empty?
      end
    end
  end

  class << self
    def update(update)
      payload = extract_message(update)

      case payload
        when Telegram::Bot::Types::Message
          response = handle(payload)
          Telegram::Response.new(payload.chat.id, response)

        when Telegram::Bot::Types::CallbackQuery
          response = handle_callback_query(payload)
          Telegram::Response.new(payload.message.chat.id, response)
      end
    end

    def handle(message)
      begin
        command = message.text.mb_chars.downcase.to_s
        execute(command, message.chat.id, message)
      rescue => ex
        ex.message
      end
    end

    def handle_callback_query(callback_query)
      begin
        command = callback_query.data.downcase.to_s
        response = execute(command, callback_query.message.chat.id, callback_query)
        TelegramMessenger.answerCallbackQuery(callback_query.id, response)

        TelegramDispatcher::CommandQueue.execute
      rescue => ex
        ex.message
      end
    end

    def execute(command, channel, message)
      case command
        when CommandRegExp::START
          TelegramMessenger.welcome(channel)
          TelegramMessenger.ask_level(channel)

          TelegramDispatcher::CommandQueue.push{ TelegramMessenger.ask_language(channel) }
          TelegramDispatcher::CommandQueue.push{ TelegramMessenger.ask_create_game(channel) }

        when CommandRegExp::LANG
          TelegramMessenger.ask_language(channel)

        when CommandRegExp::LANG_ALPHA
          language = GameEngineService.get_language_or_default($~['language'].upcase)
          GameEngineService.settings(channel, {language: language})
          TelegramMessenger.language(language)

        when CommandRegExp::CREATE
          TelegramMessenger.ask_create_game(channel)

        when CommandRegExp::CREATE_ALPHA
          TelegramDispatcher::CommandQueue.clear
          game = GameEngineService.create_by_word(channel, $~['secret'], :telegram)
          TelegramMessenger.game_created(game)

        when CommandRegExp::CREATE_DIGIT
          TelegramDispatcher::CommandQueue.clear
          game = GameEngineService.create_by_number(channel, $~['number'], :telegram)
          TelegramMessenger.game_created(game)

        when CommandRegExp::GUESS
          guess = GameEngineService.guess(channel, message.from.username, $~['guess'])
          TelegramMessenger.guess(guess)

        when CommandRegExp::HINT
          letter = GameEngineService.hint(channel)
          TelegramMessenger.hint(letter)

        when CommandRegExp::HINT_ALPHA
          letter = GameEngineService.hint(channel, $~['letter'])
          letter.present? ? TelegramMessenger.hint($~['letter']) : TelegramMessenger.no_hint($~['letter'])

        when CommandRegExp::TRIES
          guesses = GameEngineService.tries(channel)
          TelegramMessenger.tries(guesses)

        when CommandRegExp::BEST
          guesses = GameEngineService.best(channel)
          TelegramMessenger.best(guesses)

        when CommandRegExp::BEST_DIGIT
          guesses = GameEngineService.best(channel,  $~['best'])
          TelegramMessenger.best(guesses)

        when CommandRegExp::ZERO
          guesses = GameEngineService.zero(channel)
          TelegramMessenger.zero(guesses)

        when CommandRegExp::LEVEL
          TelegramMessenger.ask_level(channel)

        when CommandRegExp::LEVEL_ALPHA
          GameEngineService.settings(channel, {complexity: $~['level']})
          TelegramMessenger.level($~['level'])

        when CommandRegExp::STOP
          if GameEngineService.stop_permitted?(message)
            game = GameEngineService.stop(channel)
            TelegramMessenger.game_stop(game)
          else
            TelegramMessenger.no_permissions_to_stop_game
          end

        when CommandRegExp::HELP
          TelegramMessenger.help

        when /^\/.*/
          TelegramMessenger.unknown_command(message)

        else
          game = Game.where(channel: channel).last
          if game.present? && !game.finished?
            guess = GameEngineService.guess(channel, message.from.username, command)
            TelegramMessenger.guess(guess)
          else
            TelegramMessenger.new_game?
          end
      end
    end

  end

  private

  def self.extract_message(update)
    update.inline_query ||
        update.chosen_inline_result ||
        update.callback_query ||
        update.edited_message ||
        update.message
  end

end
