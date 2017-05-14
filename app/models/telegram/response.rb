class Telegram::Response

  attr_value :channel, :text, :mode, :method

  def initialize(channel, text, mode = 'Markdown', method = 'sendMessage')
    @text = text.class == String ? text : ''
    @chat_id = channel
    @parse_mode = mode || 'Markdown'
    @method = method
  end

end
