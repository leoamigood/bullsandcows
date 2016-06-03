class TelegramDispatcher

  @@WELCOME_MSG = 'Welcome to Bulls and Cows! Here be dragons! Well, the rules actually.'

  def self.handle(message)
    command = message.text.mb_chars.downcase.to_s
    case command
      when /^\/start/
        TelegramService.start

      when /^\/create$/
        TelegramService.create(message.chat.id)

      when /^\/create ([[:alpha:]]+)/
        TelegramService.create_by_word(message.chat.id, $1)

      when /^\/create ([[:digit:]]+)/
        TelegramService.create_by_number(message.chat.id ,$1)

      when /^\/guess ([[:alpha:]]+)/
        TelegramService.guess(message.chat.id, message.from.username, $1)

      when /^\/hint$/
        TelegramService.hint(message.chat.id)

      when /^\/tries$/
        TelegramService.tries(message.chat.id)

      when /^\/stop$/
        if (TelegramService.stop_permitted(message))
          TelegramService.stop(message.chat.id)
        else
          'You are NOT allowed to _/stop_ this game. Only _admin_ or _creator_ is'
        end

      when /^\/help$/
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