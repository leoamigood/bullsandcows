require 'airbrake'

module Telegram
  class TelegramDispatcher
    class << self
      def update(update)
        payload, chat_id = extract_message(update)
        return unless payload.present?
        begin
          response, mode = *payload.handle
          Telegram::Response.new(chat_id, response, mode || 'Markdown')
        rescue Errors::GameException => ex
          log_error(ex, update)
          Telegram::Response.new(chat_id, ex.message)
        rescue => ex
          log_error(ex, update)
        end
      end

      def log_error(ex, update)
        unless Rails.env == 'test'
          Airbrake.notify_sync(ex, update.to_h)
          Rails.logger.warn("Error: #{ex.message}, Update: #{update.to_json}")
        end
      end

      private

      def extract_message(update)
        return update.callback_query, update.callback_query.message.chat.id if update.callback_query.present?
        return update.inline_query, nil if update.inline_query.present?
        return update.message, update.message.chat.id if update.message.present?
      end
    end
  end
end
