require 'telegram/bot'

token = '228214841:AAGjFhBb_AzPBAy0h47GO9mTX03CnV_y3vc'

unless Rails.env.test?
  Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
    bot.listen do |message|
      TelegramService.listen(bot, message) if message.present?
    end
  end
end
