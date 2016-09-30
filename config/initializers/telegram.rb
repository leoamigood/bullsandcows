require 'telegram/bot'

token = ENV['TELEGRAM_API_TOKEN']

if Rails.env.production?
  Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
    bot.api.setWebhook({'url' => "#{ENV['TELEGRAM_URL']}/#{ENV['TELEGRAM_WEBHOOK']}"})
  end
end
