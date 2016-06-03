require 'rails_helper'

describe Telegram::Response, type: :model do

  context 'with a constructed telegram message' do
    let!(:message) { Telegram::Response.new('channel_id', 'formatted reply _text_')}

    it 'serialize message as json' do
      expect(message.as_json).to include('parse_mode', 'chat_id' => 'channel_id', 'text' => 'formatted reply _text_')
    end
  end
end