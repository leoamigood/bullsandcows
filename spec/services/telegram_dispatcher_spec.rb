require 'rails_helper'

describe TelegramDispatcher, type: :service do
  let!(:channel) { Random.rand(@MAX_INT_VALUE) }
  let!(:user) { User.new(id = Random.rand(@MAX_INT_VALUE), name = '@Amig0') }

  let!(:realm) { build :realm, :telegram, channel: channel, user_id: user.id }

  let!(:english) { create :dictionary, :english}
  let!(:russian) { create :dictionary, :russian}

  context 'when game has not been created' do

    context 'when /start command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/start') }

      before do
        allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

        message.stub_chain(:chat, :id).and_return(channel)
      end

      let(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

      it 'replies with a welcome text' do
        expect {
          expect(TelegramDispatcher.handle(message)).to be
          expect(TelegramMessenger).to have_received(:send_message).with(channel, /Welcome to Bulls and Cows!/).once
          expect(TelegramMessenger).to have_received(:send_message).with(channel, 'Select game language:', markup).once
        }.to change(Telegram::CommandQueue::Queue.new(channel), :size).by(3)
      end
    end

    context 'when /create command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/create') }

      before do
        allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

        message.stub_chain(:chat, :id).and_return(channel)
      end

      let(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

      it 'replies with a prompt to specify word length' do
        expect(TelegramDispatcher.handle(message)).to be
        expect(TelegramMessenger).to have_received(:send_message).with(channel, 'How many letters will it be?', markup)
      end
    end

    context 'when /create <word> command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/create коитус') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
      end

      it 'replies with a game created text' do
        expect(TelegramDispatcher.handle(message)).to include('Game created: 6 letters.')
      end
    end

    context 'when /create multiple spaces in between <word> command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/create коитус') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
      end

      it 'replies with a game created text' do
        expect(TelegramDispatcher.handle(message)).to include('Game created: 6 letters.')
      end
    end

    context 'when /create <number> command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/create 6') }

      let!(:medium) { create :dictionary_level, :medium_en }
      let!(:settings) { create :setting, channel: channel, language: 'EN', dictionary: english, complexity: 'medium'}

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
      end

      it 'replies with a game created text' do
        expect(TelegramDispatcher.handle(message)).to include('Game created: 6 letters. Language: EN.')
      end
    end

    context 'when /create command includes bot name received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/create@BullsAndCowsWordsBot секрет') }

      before do
        allow(GameEngineService).to receive(:create_by_word)
        allow(TelegramMessenger).to receive(:game_created)

        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
      end

      it 'handles bot name as optional part in command' do
        expect(TelegramDispatcher.handle(message))
        expect(GameEngineService).to have_received(:create_by_word).with(realm, 'секрет')
      end
    end

    context 'when /level command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/level') }

      before do
        allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

        message.stub_chain(:chat, :id).and_return(channel)
      end

      let(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

      it 'replies with prompt to submit game level' do
        expect {
          TelegramDispatcher.handle(message)
          expect(TelegramMessenger).to have_received(:send_message).with(channel, 'Select game level:', markup)
        }.not_to change(Game, :count)
      end
    end

    context 'when /level command received with selected level' do
      let!(:callbackQuery) { Telegram::Bot::Types::CallbackQuery.new(id: 729191086489033331, data: '/level easy') }

      before do
        allow(TelegramMessenger).to receive(:answerCallbackQuery)
        allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

        callbackQuery.stub_chain(:message, :chat, :id).and_return(channel)
      end

      context 'being last command in command queue' do
        before do
          allow(Telegram::CommandQueue).to receive(:present?).and_return(false)
        end

        it 'creates setting with selected game level and response with inline message' do
          expect {
            expect(TelegramDispatcher.handle_callback_query(callbackQuery)).to eq('Game level was set to easy.')
            expect(TelegramMessenger).not_to have_received(:answerCallbackQuery)
          }.to change(Setting, :count).by(1)
        end
      end

      context 'NOT being last command in command queue' do
        before do
          allow_any_instance_of(Telegram::CommandQueue::Queue).to receive(:present?).and_return(true)
          allow_any_instance_of(Telegram::CommandQueue::Queue).to receive(:execute)
        end

        it 'creates setting with selected game level and response with inline message' do
          expect {
            expect(TelegramDispatcher.handle_callback_query(callbackQuery)).to be_nil
            expect(TelegramMessenger).to have_received(:answerCallbackQuery).with(callbackQuery.id, 'Game level was set to easy.').once
          }.to change(Setting, :count).by(1)
        end
      end
    end

    context 'when /lang command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/lang') }

      before do
        allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

        message.stub_chain(:chat, :id).and_return(channel)
      end

      let(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

      it 'replies with prompt to submit game language' do
        expect {
          TelegramDispatcher.handle(message)
          expect(TelegramMessenger).to have_received(:send_message).with(channel, 'Select game language:', markup)
        }.not_to change(Game, :count)
      end
    end

    context 'when /lang command received with selected language' do
      let!(:callbackQuery) { Telegram::Bot::Types::CallbackQuery.new(id: 729191086489033331, data: '/lang RU') }

      before do
        allow(TelegramMessenger).to receive(:answerCallbackQuery)
        allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

        callbackQuery.stub_chain(:message, :chat, :id).and_return(channel)
      end

      context 'being last command in command queue' do
        before do
          allow(Telegram::CommandQueue).to receive(:present?).and_return(false)
        end

        it 'creates setting with selected game language and response with inline message' do
          expect {
            expect(TelegramDispatcher.handle_callback_query(callbackQuery)).to eq('Language was set to Русский.')
            expect(TelegramMessenger).not_to have_received(:answerCallbackQuery)
          }.to change(Setting, :count).by(1)
        end
      end

      context 'NOT being last command in command queue' do
        before do
          allow_any_instance_of(Telegram::CommandQueue::Queue).to receive(:present?).and_return(true)
          allow_any_instance_of(Telegram::CommandQueue::Queue).to receive(:execute)
        end

        it 'creates setting with selected game language and response with status message' do
          expect {
            expect(TelegramDispatcher.handle_callback_query(callbackQuery)).to be_nil
            expect(TelegramMessenger).to have_received(:answerCallbackQuery).with(callbackQuery.id, 'Language was set to Русский.').once
          }.to change(Setting, :count).by(1)
        end
      end
    end

    context 'when /tries command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/tries') }

      before do
        allow(Telegram::Action::Tries).to receive(:execute)
        message.stub_chain(:chat, :id).and_return(channel)
      end

      it 'errors out with message about no recent games available' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('No recent game to show _/tries_ guesses on.')
          expect(Telegram::Action::Tries).not_to have_received(:execute)
        }.not_to change(Guess, :count)
      end
    end

    context 'when /best command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/best') }

      before do
        allow(Telegram::Action::Best).to receive(:execute)
        message.stub_chain(:chat, :id).and_return(channel)
      end

      it 'errors out with message about no recent games available' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('No recent game to show _/best_ guesses on.')
          expect(Telegram::Action::Best).not_to have_received(:execute)
        }.not_to change(Guess, :count)
      end
    end

    context 'when /zero command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/zero') }

      before do
        allow(Telegram::Action::Zero).to receive(:execute)
        message.stub_chain(:chat, :id).and_return(channel)
      end

      it 'errors out with message about no recent games available' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('No recent game to show _/zero_ guesses on.')
          expect(Telegram::Action::Zero).not_to have_received(:execute)
        }.not_to change(Guess, :count)
      end
    end

    context 'when non command guess word received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: 'secret') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'ignores the message' do
        expect {
          expect(TelegramDispatcher.handle(message)).to be_nil
        }.not_to change(Guess, :count)
      end
    end
  end

  context 'when game has just started and had no guesses placed' do
    let!(:game) { create(:game, :realm, secret: 'secret', realm: realm, status: :created, dictionary: english) }

    context 'when /best command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/best') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
      end

      it 'replies with no guesses message' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('There was no guesses so far')
        }.not_to change(Guess, :count)
      end
    end

    context 'when /suggest command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/suggest') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'suggests a word with matching number of letters' do
        expect {
          expect(TelegramDispatcher.handle(message)).to match('Suggestion: _\w{6}_')
        }.to change{ game.guesses.count }.by(1)
      end
    end

    context 'when /lang command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/lang') }

      before do
        allow(Telegram::Action::Language).to receive(:execute)
        message.stub_chain(:chat, :id).and_return(channel)
      end

      it 'errors out with message about permissions' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('You are NOT allowed to change game language.')
          expect(Telegram::Action::Language).not_to have_received(:execute)
        }.not_to change(Game, :count)
      end
    end

    context 'when /level command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/level') }

      before do
        allow(Telegram::Action::Level).to receive(:execute)
        message.stub_chain(:chat, :id).and_return(channel)
      end

      it 'errors out with message about permissions' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('You are NOT allowed to change game level.')
          expect(Telegram::Action::Level).not_to have_received(:execute)
        }.not_to change(Game, :count)
      end
    end
  end

  context 'when game is in progress and has multiple guesses placed' do
    let!(:game) { create(:game, :realm, :with_tries, secret: 'secret', realm: realm,  status: :running, dictionary: english) }

    context 'when /guess command received with non-exact guess word' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/guess flight') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'replies with guess result' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('Guess 11: _flight_')
          expect(game.reload.running?).to eq(true)
        }.to change(Guess, :count).by(1)
      end
    end

    context 'when /guess command received case sensitive guess word' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/guess Secret') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'handles case sensitive case' do
        expect {
          TelegramDispatcher.handle(message)
          expect(game.reload.finished?).to eq(true)
        }.to change(Guess, :count).by(1)
      end
    end

    context 'when /guess command received with incorrect amount of letters in word' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/guess mistake') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'replies with error message' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('Your guess word _mistake_ (*7*) has to be *6* letters long.')
        }.not_to change(Guess, :count)
      end
    end

    context 'when /guess command received with exact guess word' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/guess secret') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'replies with congratulations' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('Congratulations!')
          expect(game.reload.finished?).to eq(true)
        }.to change(Guess, :count).by(1)
      end
    end

    context 'when /guess command includes bot name received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/guess@BullsAndCowsWordsBot secret') }

      before do
        allow(GameEngineService).to receive(:guess)
        allow(TelegramMessenger).to receive(:guess)

        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'handles bot name as optional part in command' do
        expect(TelegramDispatcher.handle(message))
        expect(GameEngineService).to have_received(:guess).with(game, user, 'secret')
      end
    end

    context 'when /tries command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/tries') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
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
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/best') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
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
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/best 3') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
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

        message.stub_chain(:chat, :id).and_return(channel)
      end

      it 'handles bot name as optional part in command' do
        expect(TelegramDispatcher.handle(message))
        expect(GameEngineService).to have_received(:best)
      end
    end

    context 'when /hint command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/hint') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
      end

      it 'reveals one letter in a secret' do
        expect {
          expect(TelegramDispatcher.handle(message)).to match(/Secret word has letter \*\w\* in it/)
        }.to change{ game.hints.count }.by(1)
      end
    end

    context 'when /hint command received with a <letter>' do
      before do
        message.stub_chain(:chat, :id).and_return(channel)
      end

      context 'with a matching letter' do
        let!(:message) { Telegram::Bot::Types::Message.new(text: '/hint c') }

        it 'reveals specified matching letter in a secret' do
          expect {
            expect(TelegramDispatcher.handle(message)).to match(/Secret word has letter \*c\* in it/)
          }.to change{ game.hints.count }.by(1)
        end
      end

      context 'with a letter that is not in secret word' do
        let!(:message) { Telegram::Bot::Types::Message.new(text: '/hint x') }

        it 'reveals the fact that the specified letter is NOT in a secret' do
          expect {
            expect(TelegramDispatcher.handle(message)).to match(/Secret word has NO letter \*x\* in it/)
          }.to change{ game.hints.count }.by(1)
        end
      end
    end

    context 'when /hint command received with a <number>' do
      before do
        message.stub_chain(:chat, :id).and_return(channel)
      end

      context 'with a matching letter' do
        let!(:message) { Telegram::Bot::Types::Message.new(text: '/hint 2') }

        it 'reveals specified number of letter in a secret' do
          expect {
            expect(TelegramDispatcher.handle(message)).to match(/Secret word has letter \*e\* in it/)
          }.to change{ game.hints.count }.by(1)
        end
      end

      context 'with a number that is over the max number of letters' do
        let!(:message) { Telegram::Bot::Types::Message.new(text: '/hint 7') }

        xit 'raises error that number is out of bounds' do
          expect {
            TelegramDispatcher.handle(message)
          }.to raise_error
        end
      end
    end

    context 'when /suggest <letters> command received with letters matching available suggestion' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/suggest re') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'suggests a word with a substring specified' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('Suggestion: _barrel_, *Bulls: 2*, *Cows: 0*.')
        }.to change{ game.guesses.count }.by(1)
      end
    end

    context 'when /suggest <letters> command received not matching any suggestions' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/suggest ku') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'finds no words to suggests based on a substring specified' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('Could not find any suggestions based on provided word letters _ku_')
        }.not_to change{ game.guesses.count }
      end
    end

    context 'when /zero command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/zero') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
      end

      it 'replies with guesses where bulls and cows have zero occurrences' do
        expect {
          result = TelegramDispatcher.handle(message)
          expect(result).to include('Zero letters in: *ballad*, Bulls: *0*, Cows: *0*.')
          expect(result).to include('Zero letters in: *quorum*, Bulls: *0*, Cows: *0*.')
        }.not_to change(Guess, :count)
      end
    end

    context 'when /stop command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/stop') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:chat, :type).and_return('group')
      end

      context 'when /stop command is permitted' do
        before do
          allow(Telegram::Validator).to receive(:permitted?).and_return(true)
        end

        it 'finishes the game, replies with a secret word' do
          expect {
            expect(TelegramDispatcher.handle(message)).to include('You give up? Here is the secret word *secret*.')
          }.to change{ game.reload.status }.to('aborted')
        end
      end

      context 'when /stop command is NOT permitted' do
        before do
          allow(Telegram::Validator).to receive(:permitted?).and_return(false)
        end

        it 'fails to stop the game, replies with a error message' do
          expect {
            expect(TelegramDispatcher.handle(message)).to include('You are NOT allowed to _/stop_ this game.')
          }.not_to change{ game.reload.status }
        end
      end
    end

    context 'when /stop command includes bot name received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/stop@BullsAndCowsWordsBot') }

      before do
        allow(Telegram::Validator).to receive(:permitted?).and_return(true)
        allow(GameService).to receive(:stop!)
        allow(TelegramMessenger).to receive(:game_was_finished)

        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:chat, :type).and_return('group')
      end

      it 'handles bot name as optional part in command' do
        expect(TelegramDispatcher.handle(message))
        expect(GameService).to have_received(:stop!).with(game)
      end
    end

    context 'when non command word received with non-exact guess' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: 'flight') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'replies with guess result' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('Guess 11: _flight_')
          expect(game.reload.running?).to eq(true)
        }.to change(Guess, :count).by(1)
      end
    end

    context 'when non command word is received with exact guess' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: 'secret') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'replies with congratulations' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('Congratulations!')
          expect(game.reload.finished?).to eq(true)
        }.to change(Guess, :count).by(1)
      end
    end

    context 'when non command multiple words is received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: 'hello world') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'ignore the message' do
        expect {
          TelegramDispatcher.handle(message)
        }.not_to change(Guess, :count)
      end
    end

    context 'when multiline non command words is received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: "line\nanother line\nthird") }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'ignore the message' do
        expect {
          expect(TelegramDispatcher.handle(message)).to be_nil
        }.not_to change(Guess, :count)
      end
    end
  end

  context 'with russian secret word game in progress' do
    let!(:game) { create(:game, :realm, secret: 'привет', realm: realm,  status: :running, dictionary: russian) }

    context 'when /guess command received case sensitive unicode guess word' do
      let!(:privet) { create(:noun, noun: 'привет')}

      let!(:message) { Telegram::Bot::Types::Message.new(text: '/guess Привет') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'handles case sensitive unicode case' do
        expect {
          TelegramDispatcher.handle(message)
          expect(game.reload.finished?).to eq(true)
        }.to change(Guess, :count).by(1)
      end
    end
  end

  context 'when game has finished' do
    let!(:game) { create(:game, :realm, :with_tries, status: :finished, secret: 'secret',  status: :finished, realm: realm) }

    context 'when /guess command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/guess secret') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
      end

      it 'replies with error message' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('Game is not running. Please _/start_ new game and try again.')
        }.not_to change(Guess, :count)
      end
    end

    context 'when /hint command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/hint') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
      end

      it 'replies with error message' do
        expect {
          expect(TelegramDispatcher.handle(message)).to include('Game is not running. Please _/start_ new game and try again.')
        }.not_to change(Hint, :count)
      end
    end

    context 'when /suggest command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/suggest') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(user.id)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'replies with error message' do
        expect {
          expect(TelegramDispatcher.handle(message)).to eq('Game is not running. Please _/start_ new game and try again.')
        }.not_to change(Hint, :count)
      end
    end

    context 'when /level command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/level') }

      before do
        allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

        message.stub_chain(:chat, :id).and_return(channel)
      end

      let(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

      it 'replies with prompt to submit game level' do
        expect {
          TelegramDispatcher.handle(message)
          expect(TelegramMessenger).to have_received(:send_message).with(channel, 'Select game level:', markup)
        }.not_to change(Game, :count)
      end
    end

    context 'when /level command received with selected level' do
      let!(:callbackQuery) { Telegram::Bot::Types::CallbackQuery.new(id: 729191086489033331, data: '/level easy') }

      before do
        allow(TelegramMessenger).to receive(:answerCallbackQuery)
        allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

        callbackQuery.stub_chain(:message, :chat, :id).and_return(channel)
      end

      context 'being last command in command queue' do
        before do
          allow(Telegram::CommandQueue).to receive(:present?).and_return(false)
        end

        it 'creates setting with selected game level and response with inline message' do
          expect {
            expect(TelegramDispatcher.handle_callback_query(callbackQuery)).to eq('Game level was set to easy.')
            expect(TelegramMessenger).not_to have_received(:answerCallbackQuery)
          }.to change(Setting, :count).by(1)
        end
      end
    end

    context 'when /lang command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/lang') }

      before do
        allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

        message.stub_chain(:chat, :id).and_return(channel)
      end

      let(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

      it 'replies with prompt to submit game language' do
        expect {
          TelegramDispatcher.handle(message)
          expect(TelegramMessenger).to have_received(:send_message).with(channel, 'Select game language:', markup)
        }.not_to change(Game, :count)
      end
    end

    context 'when /lang command received with selected language' do
      let!(:callbackQuery) { Telegram::Bot::Types::CallbackQuery.new(id: 729191086489033331, data: '/lang RU') }

      before do
        allow(TelegramMessenger).to receive(:answerCallbackQuery)
        allow(TelegramMessenger).to receive(:send_message).and_return(Telegram::Bot::Types::Message.new)

        callbackQuery.stub_chain(:message, :chat, :id).and_return(channel)
      end

      context 'being last command in command queue' do
        before do
          allow(Telegram::CommandQueue).to receive(:present?).and_return(false)
        end

        it 'creates setting with selected game language and response with inline message' do
          expect {
            expect(TelegramDispatcher.handle_callback_query(callbackQuery)).to eq('Language was set to Русский.')
            expect(TelegramMessenger).not_to have_received(:answerCallbackQuery)
          }.to change(Setting, :count).by(1)
        end
      end
    end

    context 'when /tries command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/tries') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
      end

      it 'replies with game guesses' do
        expect {
          expect(TelegramDispatcher.handle(message)).to match('Try .* Bulls: .* Cows: .*')
        }.not_to change(Guess, :count)
      end
    end

    context 'when /best command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/best') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
      end

      it 'replies with top guesses' do
        expect {
          expect(TelegramDispatcher.handle(message)).to match('Top .* Bulls: .* Cows: .*')
        }.not_to change(Guess, :count)
      end
    end

    context 'when /zero command received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/zero') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
      end

      it 'replies with guesses where bulls and cows have zero occurrences' do
        expect {
          expect(TelegramDispatcher.handle(message)).to match('Zero letters in:')
        }.not_to change(Guess, :count)
      end
    end

    context 'when non command guess word received' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: 'secret') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :username).and_return(user.name)
      end

      it 'ignores the message' do
        expect {
          expect(TelegramDispatcher.handle(message)).to be_nil
          expect(game.reload.finished?).to eq(true)
        }.not_to change(Guess, :count)
      end
    end
  end

  context 'when /help command received' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: '/help') }

    before do
      message.stub_chain(:chat, :id).and_return(channel)
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
      message.stub_chain(:chat, :id).and_return(channel)
    end

    it 'replies with generic message' do
      expect(TelegramDispatcher.handle(message)).to include('Nothing I can do')
    end
  end

end

