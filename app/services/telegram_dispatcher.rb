class TelegramDispatcher

  @@BOT_NAME = 'BullsAndCowsWordsBot'

  class << self
    def handle(message)
      begin
        command = message.text.mb_chars.downcase.to_s
        execute(command, message)
      rescue => ex
        ex.message
      end
    end

    def execute(command, message)
      case command
        when /^\/start/
          TelegramMessenger.welcome

        when /^\/create(?:@#{@@BOT_NAME})?$/i
          game = TelegramService.create(message.chat.id)
          TelegramMessenger.create(game)

        when /^\/create(?:@#{@@BOT_NAME})? ([[:alpha:]]+)$/i
          game = TelegramService.create_by_word(message.chat.id, $1)
          TelegramMessenger.create(game)

        when /^\/create(?:@#{@@BOT_NAME})? ([[:digit:]]+)$/i
          game = TelegramService.create_by_number(message.chat.id, $1)
          TelegramMessenger.create(game)

        when /^\/guess(?:@#{@@BOT_NAME})? ([[:alpha:]]+)$/i
          guess = TelegramService.guess(message.chat.id, message.from.username, $1)
          TelegramMessenger.guess(guess)

        when /^\/hint(?:@#{@@BOT_NAME})?$/i
          letter = TelegramService.hint(message.chat.id)
          TelegramMessenger.hint(letter)

        when /^\/tries(?:@#{@@BOT_NAME})?$/i
          guesses = TelegramService.tries(message.chat.id)
          TelegramMessenger.tries(guesses)

        when /^\/best(?:@#{@@BOT_NAME})?$/i
          guesses = TelegramService.best(message.chat.id)
          TelegramMessenger.best(guesses)

        when /^\/best(?:@#{@@BOT_NAME})? ([[:digit:]]+)$/i
          guesses = TelegramService.best(message.chat.id, $1)
          TelegramMessenger.best(guesses)

        when /^\/zeros(?:@#{@@BOT_NAME})?$/i
          guesses = TelegramService.zeros(message.chat.id)
          TelegramMessenger.zeros(guesses)

        when /^\/stop(?:@#{@@BOT_NAME})?$/i
          if TelegramService.stop_permitted?(message)
            game = TelegramService.stop(message.chat.id)
            TelegramMessenger.stop(game)
          else
            TelegramMessenger.no_permissions_to_stop_game
          end

        when /^\/help(?:@#{@@BOT_NAME})?$/i
          TelegramMessenger.help

        when /^\/.*/
          TelegramMessenger.unknown_command(message)

        else
          game = Game.where(channel: message.chat.id).last
          if game.present? && !game.finished?
            guess = TelegramService.guess(message.chat.id, message.from.username, command)
            TelegramMessenger.guess(guess)
          else
            TelegramMessenger.new_game?
          end
      end
    end
  end

end
