class TelegramController

  @@WELCOME_MSG = 'Welcome to Bulls and Cows! Here be dragons! Well, the rules actually.'

  def listen(bot, message)
    begin
      self.handle(bot, message)
    rescue => ex
      begin
        bot.logger.info("Error: #{ex.message}")
        bot.api.send_message(chat_id: message.chat.id, text: "Error: #{ex.message}", parse_mode: 'Markdown')
      rescue => internal
        bot.logger.info("Error: #{internal.message}")
      end
    end
  end

  def handle(bot, message)
    command = message.text.mb_chars.downcase.to_s
    case command
      when /^\/start/
        reply = TelegramService.start
        bot.api.send_message(chat_id: message.chat.id, text: reply)

      when /^\/create$/
        reply = TelegramService.create
        bot.api.send_message(chat_id: message.chat.id, text: reply, parse_mode: 'Markdown')

      when /^\/create ([[:alpha:]]+)/
        reply = TelegramService.create_by_word($1)
        bot.api.send_message(chat_id: message.chat.id, text: reply, parse_mode: 'Markdown')

      when /^\/create ([[:digit:]]+)/
        reply = TelegramService.create_by_number($1)
        bot.api.send_message(chat_id: message.chat.id, text: reply, parse_mode: 'Markdown')

      when /^\/guess ([[:alpha:]]+)/
        reply = TelegramService.guess(message.chat.id, message.from.username, $1)
        bot.api.send_message(chat_id: message.chat.id, text: reply, parse_mode: 'Markdown')

      when /^\/hint$/
        reply = TelegramService.hint(message.chat.id)
        bot.api.send_message(chat_id: channel, text: reply, parse_mode: 'Markdown')

      when /^\/tries$/
        reply = TelegramService.tries(message.chat.id)
        bot.api.send_message(chat_id: channel, text: reply, parse_mode: 'Markdown')

      when /^\/stop$/
        if (TelegramService.stop_permitted(bot, message))
          reply = TelegramService.stop(message.chat.id)
          bot.api.send_message(chat_id: channel, text: reply, parse_mode: 'Markdown')
        else
          reply = 'You are NOT allowed to _/stop_ this game. Only _admin_ or _creator_ is'
          bot.api.send_message(chat_id: channel, text: reply, parse_mode: 'Markdown')
        end

      when /^\/help$/
        reply = TelegramService.help
        bot.api.send_message(chat_id: channel, text: reply, parse_mode: 'Markdown')

      else
        game = Game.where(channel: message.chat.id).last
        if game.present?
          unless game.finished?
            guess(bot, message.chat.id, message.from.username, command)
          else
            bot.api.send_message(chat_id: message.chat.id, text: 'Go ahead and _/create_ a new game. For help try _/help_', parse_mode: 'Markdown')
          end
        else
          bot.api.send_message(chat_id: message.chat.id, text: "Nothing I can do with *#{message}*. For help try _/help_", parse_mode: 'Markdown')
        end
    end
  end

end