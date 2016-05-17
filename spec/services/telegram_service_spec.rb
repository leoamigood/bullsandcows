require 'rails_helper'

describe TelegramService, type: :service do

  let!(:token) { 'api_token:goes_here' }
  let!(:bot) { Telegram::Bot::Client.new(token) }
  let!(:api) { Telegram::Bot::Api.new(token) }

  before(:each) do
    allow(bot).to receive(:api).and_return(api)
    allow(api).to receive(:send_message)
  end

  context 'when start command received' do
    let!(:chat_id) { 169778030 }
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/start') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'replies with a welcome text' do
      TelegramService.listen(bot, message)

      expect(api).to have_received(:send_message).with(hash_including(:text, chat_id: chat_id))
    end
  end

end