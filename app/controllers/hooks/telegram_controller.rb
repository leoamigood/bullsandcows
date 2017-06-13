require 'airbrake'

class Hooks::TelegramController < BaseApiController

  Rails.logger = Logger.new(STDOUT)

  def update
    begin
      update = Telegram::Bot::Types::Update.new(telegram_params)
      response = Telegram::TelegramDispatcher.update(update)
      Rails.logger.info("Telegram: Update: #{update.update_id}, Response: #{response.to_json}")

      render json: response
    rescue => ex
      Rails.logger.warn("Error: #{ex.message}, Stacktrace: #{ex.backtrace}")
      Airbrake.notify(ex, params.to_h)
      render json: ex.message
    end
  end

  private

  def telegram_params
    message = [
        :message_id,
        :text,
        :date,
        from: [:id, :first_name, :last_name, :username, :language_code],
        chat: [:id, :first_name, :last_name, :username, :type]
    ]

    params.permit(
        :update,
        :data,
        message: message,
        edited_message: message,
        inline_query: [
            :id,
            :query,
            from: [:id, :first_name, :last_name, :username, :language_code]
        ],
        callback_query: [
            :id,
            :data,
            from: [:id, :first_name, :last_name, :username, :language_code],
            message: message
        ]
    )
  end
end
