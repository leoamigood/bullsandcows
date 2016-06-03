class TelegramController < BaseApiController

  def update
    Rails.logger.info("Telegram web hook hit: #{params}")

    message = params['message']
    
    lines = ['Use _/create [number]_ to create a game', 'Use _/guess <word>_ to guess the secret word', 'Use _/tries_ to show previous attempts', 'Use _/hint_ reveals one letter']
    payload = Message.new(message.chat_id, lines.join(' '))

    render json: payload
  end

end