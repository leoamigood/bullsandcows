require 'telegram/bot'

token = ENV['TELEGRAM_API_TOKEN']

unless Rails.env.test?
  Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
    bot.api.setWebhook({'url' => "https://bullsandcowsbot.herokuapp.com/hooks/telegram/#{ENV['TELEGRAM_WEBHOOK']}"})
  end
end
