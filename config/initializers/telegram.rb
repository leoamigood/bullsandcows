require 'telegram/bot'

TELEGRAM_TOKEN = ENV['TELEGRAM_API_TOKEN']

unless Rails.env.test? || $0 =~ /rake$/
  Telegram::Bot::Client.run(TELEGRAM_TOKEN, logger: Logger.new($stderr)) do |bot|
    bot.api.setWebhook({'url' => "#{ENV['TELEGRAM_URL']}/#{ENV['TELEGRAM_WEBHOOK']}"})
  end
end
