class Telegram::Response

  attr_value :channel, :text, :mode, :method

  def initialize(channel, response, mode = 'Markdown', method = 'sendMessage')
    @text = response.class == String ? response : ''
    @reply_markup = response.class == Telegram::Bot::Types::ReplyKeyboardMarkup ? response : nil
    @chat_id = channel
    @parse_mode = mode || 'Markdown'
    @method = method
  end

end
