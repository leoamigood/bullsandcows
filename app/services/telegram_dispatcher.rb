class TelegramDispatcher

  @@BOT_NAME = 'BullsAndCowsWordsBot'

  class << self
    def update(update)
      message = extract_message(update)
      case message
        when Telegram::Bot::Types::Message
          response = handle(message)
          Telegram::Response.new(message.chat.id, response)

        when Telegram::Bot::Types::CallbackQuery
          response = handle_callback(message)
          Telegram::Response.new(message.message.chat.id, response)
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

    def handle_callback(message)
      begin
        command = message.data.downcase.to_s
        execute(command, message.message.chat.id, message)
      rescue => ex
        ex.message
      end
    end

    def execute(command, channel, message)
      case command
        when /^\/start/
          TelegramMessenger.welcome(message)

        when /^\/create(?:@#{@@BOT_NAME})?$/i
          game = TelegramService.create(channel)
          TelegramMessenger.create(game)

        when /^\/create(?:@#{@@BOT_NAME})? ([[:alpha:]]+)$/i
          game = TelegramService.create_by_word(channel, $1)
          TelegramMessenger.create(game)

        when /^\/create(?:@#{@@BOT_NAME})? ([[:digit:]]+)$/i
          game = TelegramService.create_by_number(channel, $1)
          TelegramMessenger.create(game)

        when /^\/guess(?:@#{@@BOT_NAME})? ([[:alpha:]]+)$/i
          guess = TelegramService.guess(channel, message.from.username, $1)
          TelegramMessenger.guess(guess)

        when /^\/hint(?:@#{@@BOT_NAME})?$/i
          letter = TelegramService.hint(channel)
          TelegramMessenger.hint(letter)

        when /^\/tries(?:@#{@@BOT_NAME})?$/i
          guesses = TelegramService.tries(channel)
          TelegramMessenger.tries(guesses)

        when /^\/best(?:@#{@@BOT_NAME})?$/i
          guesses = TelegramService.best(channel)
          TelegramMessenger.best(guesses)

        when /^\/best(?:@#{@@BOT_NAME})? ([[:digit:]]+)$/i
          guesses = TelegramService.best(channel, $1)
          TelegramMessenger.best(guesses)

        when /^\/zeros(?:@#{@@BOT_NAME})?$/i
          guesses = TelegramService.zeros(channel)
          TelegramMessenger.zeros(guesses)

        when /^\/level(?:@#{@@BOT_NAME})? ([[:alpha:]]+)$/i
          levels = TelegramService.level($1)
          game = TelegramService.create(channel, levels)
          TelegramMessenger.create(game)

        when /^\/stop(?:@#{@@BOT_NAME})?$/i
          if TelegramService.stop_permitted?(message)
            game = TelegramService.stop(channel)
            TelegramMessenger.stop(game)
          else
            TelegramMessenger.no_permissions_to_stop_game
          end

        when /^\/help(?:@#{@@BOT_NAME})?$/i
          TelegramMessenger.help

        when /^\/.*/
          TelegramMessenger.unknown_command(message)

        else
          game = Game.where(channel: channel).last
          if game.present? && !game.finished?
            guess = TelegramService.guess(channel, message.from.username, command)
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
