class Hooks::TelegramController < BaseApiController

  Rails.logger = Logger.new(STDOUT)

  def update
    begin
      Rails.logger.info("Telegram request: #{params}")

      payload = telegram_params[:message]
      payload = telegram_params[:edited_message] unless payload.present?
      message = Telegram::Bot::Types::Message.new(payload.to_hash)

      reply = TelegramDispatcher.handle(message)
      response = Telegram::Response.new(message['chat']['id'], reply)

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
    params.permit(message: message, edited_message: message)
  end
end