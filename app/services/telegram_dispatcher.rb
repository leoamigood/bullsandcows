class TelegramDispatcher

  @@BOT_NAME = 'BullsAndCowsWordsBot'
  @@WELCOME_MSG = 'Welcome to Bulls and Cows! Here be dragons! Well, the rules actually.'

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
          TelegramService.start

        when /^\/create(?:@#{@@BOT_NAME})?$/i
          TelegramService.create(message.chat.id)

        when /^\/create(?:@#{@@BOT_NAME})? ([[:alpha:]]+)/i
          TelegramService.create_by_word(message.chat.id, $1)

        when /^\/create(?:@#{@@BOT_NAME})? ([[:digit:]]+)/i
          TelegramService.create_by_number(message.chat.id, $1)

        when /^\/guess(?:@#{@@BOT_NAME})? ([[:alpha:]]+)/i
          TelegramService.guess(message.chat.id, message.from.username, $1)

        when /^\/hint(?:@#{@@BOT_NAME})?$/i
          TelegramService.hint(message.chat.id)

        when /^\/tries(?:@#{@@BOT_NAME})?$/i
          TelegramService.tries(message.chat.id)

        when /^\/stop(?:@#{@@BOT_NAME})?$/i
          if (TelegramService.stop_permitted(message))
            TelegramService.stop(message.chat.id)
          else
            'You are NOT allowed to _/stop_ this game. Only _admin_ or _creator_ is'
          end

        when /^\/help(?:@#{@@BOT_NAME})?$/i
          TelegramService.help

        when /^\/.*/
          "Nothing I can do with *#{message}*. For help try _/help_"

        else
          game = Game.where(channel: message.chat.id).last
          if game.present? && !game.finished?
            TelegramService.guess(message.chat.id, message.from.username, command)
          else
            'Go ahead and _/create_ a new game. For help try _/help_'
          end
      end
    end
  end

end