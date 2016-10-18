require 'rails_helper'

describe TelegramDispatcher, type: :dispatcher do
  let!(:user) { '@Amig0' }
  let!(:chat_id) { 169778030 }

  let!(:dictionary) { create :dictionary, :basic, lang: 'RU'}

  context 'when /start command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/start') }

    before do
      allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    let(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

    it 'replies with a welcome text' do
      expect(TelegramDispatcher.handle(message)).to be
      expect(TelegramMessenger).to have_received(:send_message).with(chat_id, /Welcome to Bulls and Cows!/).once
      expect(TelegramMessenger).to have_received(:send_message).with(chat_id, 'Select game level:', markup).once
    end
  end

  context 'when /lang command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/lang') }

    before do
      allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    let(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

    it 'replies with prompt to submit game language' do
      expect {
        TelegramDispatcher.handle(message)
        expect(TelegramMessenger).to have_received(:send_message).with(chat_id, 'Select game language:', markup)
      }.not_to change(Game, :count)
    end
  end

  context 'when /lang command received with selected language' do
    let!(:callbackQuery) { Telegram::Bot::Types::CallbackQuery.new(id: 729191086489033331, data: '/lang Russian') }

    before do
      allow(TelegramMessenger).to receive(:answerCallbackQuery)
      allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

      callbackQuery.stub_chain(:message, :chat, :id).and_return(chat_id)
    end

    it 'creates setting with selected game language' do
      expect {
        expect(TelegramDispatcher.handle_callback_query(callbackQuery)).to eq('Language was set to Russian')
        expect(TelegramMessenger).to have_received(:answerCallbackQuery).with(callbackQuery.id).once
      }.to change(Setting, :count).by(1)
    end
  end

  context 'when /create command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/create') }

    before do
      allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    let(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

    it 'replies with a prompt to specify word length' do
      expect(TelegramDispatcher.handle(message)).to be
      expect(TelegramMessenger).to have_received(:send_message).with(chat_id, 'How many letters would it be?', markup)
    end
  end


  context 'when /create <word> command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/create коитус') }

    before do
      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'replies with a game created text' do
      expect(TelegramDispatcher.handle(message)).to include('Game created with *6* letters in the secret word')
    end
  end

  context 'when /create multiple spaces in between <word> command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/create         коитус') }

    before do
      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'replies with a game created text' do
      expect(TelegramDispatcher.handle(message)).to include('Game created with *6* letters in the secret word')
    end
  end

  context 'when /create <number> command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/create 6') }

    before do
      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'replies with a game created text' do
      expect(TelegramDispatcher.handle(message)).to include('Game created with *6* letters in the secret word')
    end
  end

  context 'when /create command includes bot name received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/create@BullsAndCowsWordsBot секрет') }

    before do
      allow(GameEngineService).to receive(:create_by_word)
      allow(TelegramMessenger).to receive(:game_created)

      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'handles bot name as optional part in command' do
      expect(TelegramDispatcher.handle(message))
      expect(GameEngineService).to have_received(:create_by_word).with(chat_id, 'секрет', :telegram)
    end
  end

  context 'when /guess command received with non-exact guess word' do
    let!(:game) { create(:game, :telegram, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/guess combat') }

    before do
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
    let!(:game) { create(:game, :telegram, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: 'Secret') }

    before do
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
    let!(:game) { create(:game, :telegram, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: 'mistake') }

    before do
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
    let!(:game) { create(:game, :telegram, secret: 'привет', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: 'Привет') }

    before do
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
    let!(:game) { create(:game, :telegram, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/guess secret') }

    before do
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
    let!(:game) { create(:game, :telegram, status: :finished, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/guess secret') }

    before do
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
      allow(GameEngineService).to receive(:guess)
      allow(TelegramMessenger).to receive(:guess)

      message.stub_chain(:chat, :id).and_return(chat_id)
      message.stub_chain(:from, :username).and_return(user)
    end

    it 'handles bot name as optional part in command' do
      expect(TelegramDispatcher.handle(message))
      expect(GameEngineService).to have_received(:guess).with(chat_id, user, 'secret')
    end
  end

  context 'when /tries command received' do
    let!(:game) { create(:game, :telegram, :telegram, :with_tries, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/tries') }

    before do
      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'replies previous guess tries' do
      expect(TelegramDispatcher.handle(message)).to include('Try 9:')
    end

    context 'when /tries command includes bot name received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/tries@BullsAndCowsWordsBot') }

      before do
        allow(GameEngineService).to receive(:tries)
        allow(TelegramMessenger).to receive(:tries)
      end

      it 'handles bot name as optional part in command' do
        expect(TelegramDispatcher.handle(message))
        expect(GameEngineService).to have_received(:tries)
      end
    end
  end

  context 'when /best command received' do
    let!(:game) { create(:game, :telegram, :telegram, :with_tries, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/best') }

    before do
      message.stub_chain(:chat, :id).and_return(chat_id)
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
    let!(:game) { create(:game, :telegram, :telegram, :with_tries, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/best 3') }

    before do
      message.stub_chain(:chat, :id).and_return(chat_id)
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
      allow(GameEngineService).to receive(:best)
      allow(TelegramMessenger).to receive(:best)

      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'handles bot name as optional part in command' do
      expect(TelegramDispatcher.handle(message))
      expect(GameEngineService).to have_received(:best)
    end
  end

  context 'when /zero command received' do
    let!(:game) { create(:game, :telegram, :telegram, :with_tries, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/zero') }

    before do
      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'replies with guesses where bulls and cows have zero occurrences' do
      expect {
        result = TelegramDispatcher.handle(message)
        expect(result).to include('Zero letters in: *ballad*, Bulls: *0*, Cows: *0*')
        expect(result).to include('Zero letters in: *quorum*, Bulls: *0*, Cows: *0*')
      }.not_to change(Guess, :count)
    end
  end

  context 'when /level command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/level') }

    before do
      allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    let(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

    it 'replies with prompt to submit game level' do
      expect {
        TelegramDispatcher.handle(message)
        expect(TelegramMessenger).to have_received(:send_message).with(chat_id, 'Select game level:', markup)
      }.not_to change(Game, :count)
    end
  end

  context 'when /level command received with selected level' do
    let!(:callbackQuery) { Telegram::Bot::Types::CallbackQuery.new(id: 729191086489033331, data: '/level easy') }

    before do
      allow(TelegramMessenger).to receive(:answerCallbackQuery)
      allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

      callbackQuery.stub_chain(:message, :chat, :id).and_return(chat_id)
    end

    it 'creates setting with selected game level' do
      expect {
        expect(TelegramDispatcher.handle_callback_query(callbackQuery)).to eq('Game level was set to easy')
        expect(TelegramMessenger).to have_received(:answerCallbackQuery).with(callbackQuery.id).once
      }.to change(Setting, :count).by(1)
    end
  end

  context 'when /stop command received' do
    let!(:game) { create(:game, :telegram, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: '/stop') }

    before do
      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    context 'when stop command is permitted' do
      before do
        allow(GameEngineService).to receive(:stop_permitted?).and_return(true)
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
      allow(GameEngineService).to receive(:stop_permitted?).and_return(true)
      allow(GameEngineService).to receive(:stop)
      allow(TelegramMessenger).to receive(:game_was_finished)

      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'handles bot name as optional part in command' do
      expect(TelegramDispatcher.handle(message))
      expect(GameEngineService).to have_received(:stop)
    end
  end

  context 'when /help command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/help') }

    before do
      message.stub_chain(:chat, :id).and_return(chat_id)
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
    
    before do
      message.stub_chain(:chat, :id).and_return(chat_id)
    end

    it 'replies with generic message' do
      expect(TelegramDispatcher.handle(message)).to include('Nothing I can do')
    end
  end

  context 'when not a command word received with non-exact guess word' do
    let!(:game) { create(:game, :telegram, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: 'combat') }

    before do
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
    let!(:game) { create(:game, :telegram, secret: 'secret', channel: chat_id) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: 'secret') }

    before do
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
