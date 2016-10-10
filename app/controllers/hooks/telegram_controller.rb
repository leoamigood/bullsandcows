class Hooks::TelegramController < BaseApiController

  Rails.logger = Logger.new(STDOUT)

  def update
    begin
      Rails.logger.info("Telegram request: #{params}")
      update = Telegram::Bot::Types::Update.new(params)
      response = TelegramDispatcher.update(update)
      Rails.logger.info("Telegram respond: #{response.to_json}")

      render json: response
    rescue => ex
      Rails.logger.warn("Error: #{ex.message}")
      render nothing: true
    end
  end

  private

  def telegram_params
    message = [:message_id, :text, :date, from: [:id, :first_name, :username], chat: [:id, :first_name, :username, :type]]
    params.permit(:data, message: message, edited_message: message, callback_query: [message: message])
  end
end
