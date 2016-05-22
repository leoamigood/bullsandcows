require 'rails_helper'

describe TelegramService, type: :service do
  let!(:chat_id) { 169778030 }

  let!(:token) { 'api_token:goes_here' }
  let!(:bot) { Telegram::Bot::Client.new(token) }
  let!(:api) { Telegram::Bot::Api.new(token) }

  before(:each) do
    allow(bot).to receive(:api).and_return(api)
    allow(api).to receive(:send_message)
  end

  context 'when /start command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/start') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'replies with a welcome text' do
      TelegramService.listen(bot, message)

      expect(api).to have_received(:send_message).with(hash_including(:text, chat_id: chat_id))
    end
  end

  let!(:secret) { create(:noun, noun: 'secret')}
  let!(:tomato) { create(:noun, noun: 'tomato') }
  let!(:mortal) { create(:noun, noun: 'mortal') }
  let!(:combat) { create(:noun, noun: 'combat') }

  context 'when /tries command received' do
    let!(:game) { create(:game, secret: 'secret', channel: chat_id) }

    let!(:try1) { create(:guess, word: 'tomato', game: game) }
    let!(:try2) { create(:guess, word: 'mortal', game: game) }
    let!(:try3) { create(:guess, word: 'combat', game: game) }
    let!(:try4) { create(:guess, word: 'secret', game: game) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/tries') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'replies previous guess tries' do
      TelegramService.listen(bot, message)

      expect(api).to have_received(:send_message).with(hash_including(:text, chat_id: chat_id)).exactly(4).times
    end
  end

end