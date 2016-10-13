class Telegram::Response

  def initialize(channel, text, mode = 'Markdown', method = 'sendMessage')
    @text = text.class == String ? text : ''
    @chat_id = channel
    @parse_mode = mode
    @method = method
  end

end
