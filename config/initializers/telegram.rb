require 'telegram/bot'

token = ENV['TELEGRAM_API_TOKEN']

unless Rails.env.test?
  # Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
  #   bot.listen do |message|
      TelegramService.listen(bot, message) if message.present?
  #   end
  # end
end
