require 'telegram/bot'

token = '228214841:AAHZuSrThClDQ2hDJtnyN4qD0SLTzWExiCw'

Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
  bot.listen do |message|
    TelegramService.listen(bot, message)
  end
end