require 'rails_helper'

describe TelegramDispatcher, type: :dispatcher do
  let!(:user) { '@Amig0' }
  let!(:chat_id) { 169778030 }

  let!(:token) { 'api_token:goes_here' }
  let!(:bot) { Telegram::Bot::Client.new(token) }
  let!(:api) { Telegram::Bot::Api.new(token) }

  let!(:secret) { create(:noun, noun: 'secret')}
  let!(:tomato) { create(:noun, noun: 'tomato') }
  let!(:mortal) { create(:noun, noun: 'mortal') }
  let!(:combat) { create(:noun, noun: 'combat') }

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
      expect(TelegramDispatcher.handle(message)).to include('Welcome to Bulls and Cows!')
    end
  end

  context 'when /create command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/create') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'replies with a game created text' do
      expect(TelegramDispatcher.handle(message)).to include('Game created with')
      expect(TelegramDispatcher.handle(message)).to include('letters in the secret word')
    end
  end


  context 'when /create <word> command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/create коитус') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'replies with a game created text' do
      expect(TelegramDispatcher.handle(message)).to include('Game created with *6* letters in the secret word')
    end
  end

  context 'when /create <number> command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/create 6') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'replies with a game created text' do
      expect(TelegramDispatcher.handle(message)).to include('Game created with *6* letters in the secret word')
    end
  end

  context 'when /guess command received with non-exact guess word' do
    let!(:game) { create(:game, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/guess combat') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'replies with guess result' do
      expect {
        TelegramDispatcher.handle(message)
        expect(game.reload.running?).to eq(true)
      }.to change(Guess, :count).by(1)
    end
  end

  context 'when /guess command received case sensitive guess word' do
    let!(:game) { create(:game, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: 'Secret') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'handles case sensitive case' do
      expect {
        TelegramDispatcher.handle(message)
        expect(game.reload.finished?).to eq(true)
      }.to change(Guess, :count).by(1)
    end
  end

  context 'when /guess command received case sensitive unicode guess word' do
    let!(:privet) { create(:noun, noun: 'привет')}
    let!(:game) { create(:game, secret: 'привет', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: 'Привет') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'handles case sensitive unicode case' do
      expect {
        TelegramDispatcher.handle(message)
        expect(game.reload.finished?).to eq(true)
      }.to change(Guess, :count).by(1)
    end
  end

  context 'when /guess command received with exact guess word' do
    let!(:game) { create(:game, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/guess secret') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'replies with congratulations' do
      expect {
        TelegramDispatcher.handle(message)
        expect(game.reload.finished?).to eq(true)
      }.to change(Guess, :count).by(1)
    end
  end

  context 'when /tries command received' do
    let!(:game) { create(:game, secret: 'secret', channel: chat_id) }

    let!(:try1) { create(:guess, word: 'tomato', game: game) }
    let!(:try2) { create(:guess, word: 'mortal', game: game) }
    let!(:try3) { create(:guess, word: 'combat', game: game) }
    let!(:try4) { create(:guess, word: 'secret', game: game) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/tries') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'replies previous guess tries' do
      expect(TelegramDispatcher.handle(message)).to include('Try 4:')
    end
  end

  context 'when /help command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/help') }

    it 'replies with help message' do
      expect(TelegramDispatcher.handle(message)).to include('Here is the list of available commands:')
    end
  end

  context 'when /unknown command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/unknown') }

    it 'replies with generic message' do
      expect(TelegramDispatcher.handle(message)).to include('Nothing I can do')
    end
  end
end