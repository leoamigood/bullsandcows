require 'telegram/bot'

TELEGRAM_TOKEN = ENV['TELEGRAM_API_TOKEN']

if Rails.env.production? || Rails.env.staging?
  Telegram::Bot::Client.run(TELEGRAM_TOKEN, logger: Logger.new($stderr)) do |bot|
    bot.api.setWebhook(
        url: "#{ENV['TELEGRAM_URL']}/#{ENV['TELEGRAM_WEBHOOK']}",
        max_connections: 80,
        allowed_updates: %w(message callback_query inline_query)
    )
  end
end
