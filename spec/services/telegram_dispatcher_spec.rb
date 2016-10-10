require 'rails_helper'

describe TelegramDispatcher, type: :dispatcher do
  let!(:user) { '@Amig0' }
  let!(:chat_id) { 169778030 }

  let!(:token) { 'api_token:goes_here' }
  let!(:bot) { Telegram::Bot::Client.new(token) }
  let!(:api) { Telegram::Bot::Api.new(token) }

  let!(:dictionary) { create :dictionary, :basic, lang: 'RU'}

  before(:each) do
    allow(bot).to receive(:api).and_return(api)
    allow(api).to receive(:send_message)
  end

  context 'when /start command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/start') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    xit 'replies with a welcome text' do
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

  context 'when /create command includes bot name received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/create@BullsAndCowsWordsBot секрет') }

    before do
      allow(TelegramService).to receive(:create_by_word)
      allow(TelegramMessenger).to receive(:create)

      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'handles bot name as optional part in command' do
      expect(TelegramDispatcher.handle(message))
      expect(TelegramService).to have_received(:create_by_word).with(chat_id, 'секрет')
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
        expect(TelegramDispatcher.handle(message)).to include('Guess: _combat_')
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

  context 'when /guess command received with incorrect amount of letters in word' do
    let!(:game) { create(:game, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: 'mistake') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'replies with error message' do
      expect {
        expect(TelegramDispatcher.handle(message)).to include('Your guess word _mistake_ has to be *6* letters long.')
      }.not_to change(Guess, :count)
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
        expect(TelegramDispatcher.handle(message)).to include('Congratulations!')
        expect(game.reload.finished?).to eq(true)
      }.to change(Guess, :count).by(1)
    end
  end

  context 'when /guess command received after game has stopped' do
    let!(:game) { create(:game, status: :finished, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/guess secret') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'replies with error message' do
      expect {
        expect(TelegramDispatcher.handle(message)).to include('Game has finished. Please start a new game using _/create_ command.')
        expect(game.reload.finished?).to eq(true)
      }.not_to change(Guess, :count)
    end
  end

  context 'when /guess command includes bot name received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/guess@BullsAndCowsWordsBot secret') }

    before do
      allow(TelegramService).to receive(:guess)
      allow(TelegramMessenger).to receive(:guess)

      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'handles bot name as optional part in command' do
      expect(TelegramDispatcher.handle(message))
      expect(TelegramService).to have_received(:guess).with(chat_id, user, 'secret')
    end
  end

  context 'when /tries command received' do
    let!(:game) { create(:game, :with_tries, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/tries') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'replies previous guess tries' do
      expect(TelegramDispatcher.handle(message)).to include('Try 9:')
    end

    context 'when /tries command includes bot name received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/tries@BullsAndCowsWordsBot') }

      before do
        allow(TelegramService).to receive(:tries)
        allow(TelegramMessenger).to receive(:tries)
      end

      it 'handles bot name as optional part in command' do
        expect(TelegramDispatcher.handle(message))
        expect(TelegramService).to have_received(:tries)
      end
    end
  end

  context 'when /best command received' do
    let!(:game) { create(:game, :with_tries, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/best') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'replies with top guesses' do
      expect {
        result = TelegramDispatcher.handle(message)
        expect(result).to include('Top 1: *sector*, Bulls: *3*, Cows: *2*')
        expect(result).to include('Top 2: *master*, Bulls: *1*, Cows: *3*')
        expect(result).to include('Top 3: *energy*, Bulls: *1*, Cows: *2*')
        expect(result).to include('Top 4: *engine*, Bulls: *1*, Cows: *2*')
        expect(result).to include('Top 5: *staple*, Bulls: *1*, Cows: *2*')
      }.not_to change(Guess, :count)
    end
  end

  context 'when /best command received with a <limit>' do
    let!(:game) { create(:game, :with_tries, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/best 3') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'replies with top <limit> guesses' do
      expect {
        result = TelegramDispatcher.handle(message)
        expect(result).to include('Top 1: *sector*, Bulls: *3*, Cows: *2*')
        expect(result).to include('Top 2: *master*, Bulls: *1*, Cows: *3*')
        expect(result).to include('Top 3: *energy*, Bulls: *1*, Cows: *2*')
        expect(result).not_to include('Top 4:')
      }.not_to change(Guess, :count)
    end
  end

  context 'when /best command includes bot name received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/best@BullsAndCowsWordsBot') }

    before do
      allow(TelegramService).to receive(:best)
      allow(TelegramMessenger).to receive(:best)

      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'handles bot name as optional part in command' do
      expect(TelegramDispatcher.handle(message))
      expect(TelegramService).to have_received(:best)
    end
  end

  context 'when /zeros command received' do
    let!(:game) { create(:game, :with_tries, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/zeros') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'replies with guesses where bulls and cows have zero occurrences' do
      expect {
        result = TelegramDispatcher.handle(message)
        expect(result).to include('Zero letters in: *ballad*, Bulls: *0*, Cows: *0*')
        expect(result).to include('Zero letters in: *quorum*, Bulls: *0*, Cows: *0*')
      }.not_to change(Guess, :count)
    end
  end

  context 'when /level command received with specified level' do
    let!(:game) { create(:game, :with_tries, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/zeros') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'replies with guesses where bulls and cows have zero occurrences' do
      expect {
        result = TelegramDispatcher.handle(message)
        expect(result).to include('Zero letters in: *ballad*, Bulls: *0*, Cows: *0*')
        expect(result).to include('Zero letters in: *quorum*, Bulls: *0*, Cows: *0*')
      }.not_to change(Guess, :count)
    end
  end

  context 'when /stop command received' do
    let!(:game) { create(:game, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/stop') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    context 'when stop command is permitted' do
      before(:each) do
        allow(TelegramService).to receive(:stop_permitted?).and_return(true)
      end

      it 'finishes the game, replies with a secret word' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('You give up? Here is the secret word *secret*')
          expect(game.reload.finished?).to eq(true)
        }.not_to change(Guess, :count)
      end
    end
  end

  context 'when /stop command includes bot name received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/stop@BullsAndCowsWordsBot') }

    before do
      allow(TelegramService).to receive(:stop_permitted?).and_return(true)
      allow(TelegramService).to receive(:stop)
      allow(TelegramMessenger).to receive(:stop)

      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'handles bot name as optional part in command' do
      expect(TelegramDispatcher.handle(message))
      expect(TelegramService).to have_received(:stop)
    end
  end

  context 'when /help command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/help') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'replies with help message' do
      expect(TelegramDispatcher.handle(message)).to include('Here is the list of available commands:')
    end

    context 'when /help command includes bot name received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/help@BullsAndCowsWordsBot') }

      before do
        allow(TelegramMessenger).to receive(:help)
      end

      it 'handles bot name as optional part in command' do
        expect(TelegramDispatcher.handle(message))
        expect(TelegramMessenger).to have_received(:help)
      end
    end
  end

  context 'when /unknown command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/unknown') }
    
    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'replies with generic message' do
      expect(TelegramDispatcher.handle(message)).to include('Nothing I can do')
    end
  end

  context 'when not a command word received with non-exact guess word' do
    let!(:game) { create(:game, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: 'combat') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'replies with guess result' do
      expect {
        expect(TelegramDispatcher.handle(message)).to include('Guess: _combat_')
        expect(game.reload.running?).to eq(true)
      }.to change(Guess, :count).by(1)
    end
  end

  context 'when not a command word is received with exact guess word' do
    let!(:game) { create(:game, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: 'secret') }

    before(:each) do
      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'replies with congratulations' do
      expect {
        expect(TelegramDispatcher.handle(message)).to include('Congratulations!')
        expect(game.reload.finished?).to eq(true)
      }.to change(Guess, :count).by(1)
    end
  end
end
