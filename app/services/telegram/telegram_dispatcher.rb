require 'airbrake'

module Telegram
  class TelegramDispatcher
    class << self
      def update(update)
        payload = extract_message(update)
        response, mode = *payload.handle
        Telegram::Response.new(payload.chat_id, response, mode || 'Markdown')
      rescue Errors::GameException => ex
        log_error(ex, update)
        Telegram::Response.new(payload.chat_id, ex.message)
      rescue StandardError => ex
        log_error(ex, update)
      end

      private

      def log_error(ex, update)
        unless Rails.env == 'test'
          Airbrake.notify_sync(ex, update.to_h)
          Rails.logger.warn("Error: #{ex.message}, Update: #{update.to_json}")
        end
      end

      def extract_message(update)
        return update.callback_query if update.callback_query.present?
        return update.inline_query if update.inline_query.present?
        return update.message if update.message.present?

        raise Errors::TelegramIOException, 'Cannot handle update - unknown message type'
      end
    end
  end
end
