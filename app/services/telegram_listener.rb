class TelegramListener

  def self.listen(bot, message)
    begin
      reply = TelegramDispatcher.handle(message)
      bot.api.send_message(chat_id: message.chat.id, text: reply)
    rescue => ex
      begin
        bot.logger.info("Error: #{ex.message}")
        bot.api.send_message(chat_id: message.chat.id, text: "Error: #{ex.message}", parse_mode: 'Markdown')
      rescue => internal
        bot.logger.info("Error: #{internal.message}")
      end
    end
  end

end