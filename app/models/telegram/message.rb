class Telegram::Message

  def initialize(channel, text, mode = 'Markdown')
    @text = text
    @chat_id = channel
    @parse_mode = mode
  end

end