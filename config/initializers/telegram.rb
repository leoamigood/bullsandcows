require 'telegram/bot'
require 'core_extensions/telegram/callback_query'
require 'core_extensions/telegram/inline_query'
require 'core_extensions/telegram/message'

Telegram::Bot::Types::CallbackQuery.include CoreExtensions::Telegram::CallbackQuery
Telegram::Bot::Types::InlineQuery.include CoreExtensions::Telegram::InlineQuery
Telegram::Bot::Types::Message.include CoreExtensions::Telegram::Message

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
