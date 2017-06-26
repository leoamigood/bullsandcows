require 'rails_helper'

describe Telegram::TelegramDispatcher, type: :service do
  let!(:user) { create :user, :telegram, :john_smith }
  let!(:realm) { build :telegram_realm, user: user }

  let!(:english) { create :dictionary, :english}
  let!(:russian) { create :dictionary, :russian}

  before do
    allow(Telegram::TelegramMessenger).to receive(:send_message).and_return(message) if defined? message
  end

  context 'when game has not been created' do
    context 'when /start command received' do
      let!(:message) { build :message, :with_realm, text: '/start', realm: realm }
      let!(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

      it 'replies with a welcome text' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to be
          expect(Telegram::TelegramMessenger).to have_received(:send_message).with(realm.channel, /Welcome to Bulls and Cows!/).once
          expect(Telegram::TelegramMessenger).to have_received(:send_message).with(realm.channel, 'Select game language:', markup).once
        }.to change(Telegram::CommandQueue::Queue.new(realm.channel), :size).by(3)
      end
    end

    context 'when /create command received' do
      let!(:message) { build :message, :with_realm, text: '/create', realm: realm }
      let!(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

      context 'without previous inline query' do
        it 'replies with a prompt to specify word length' do
          expect(Telegram::TelegramDispatcher.handle(message)).to be
          expect(Telegram::TelegramMessenger).to have_received(:send_message).with(realm.channel, 'How many letters will it be?', markup)
        end
      end

      context 'with previous user inline query' do
        before do
          allow_any_instance_of(Telegram::CommandQueue::UserQueue).to receive(:pop).and_return('/create игра')
        end

        it 'replies with a game created text' do
          expect(Telegram::TelegramDispatcher.handle(message)).to include('Game created: *4* letters.')
        end
      end

    end

    context 'when /create <word> command received' do
      let!(:message) { build :message, :with_realm, text: '/create коитус', realm: realm }

      it 'replies with a game created text' do
        expect(Telegram::TelegramDispatcher.handle(message)).to include('Game created: *6* letters.')
      end
    end

    context 'when /create multiple spaces in between <word> command received' do
      let!(:message) { build :message, :with_realm, text: '/create     коитус', realm: realm }

      it 'replies with a game created text' do
        expect(Telegram::TelegramDispatcher.handle(message)).to include('Game created: *6* letters.')
      end
    end

    context 'when /create <number> command received' do
      let!(:medium) { create :dictionary_level, :medium_en, dictionary_id: english.id }
      let!(:settings) { create :setting, channel: realm.channel, language: 'EN', dictionary: english, complexity: 'medium'}

      let!(:message) { build :message, :with_realm, text: '/create 6', realm: realm }

      it 'replies with a game created text' do
        expect(Telegram::TelegramDispatcher.handle(message)).to include('Game created: *6* letters. Language: *EN*.')
      end
    end

    context 'when /create command includes bot name received' do
      let!(:message) { build :message, :with_realm, text: '/create@BullsAndCowsWordsBot секрет', realm: realm }

      before do
        allow(GameEngineService).to receive(:create_by_word)
        allow(Telegram::TelegramMessenger).to receive(:game_created)
      end

      it 'handles bot name as optional part in command' do
        expect(Telegram::TelegramDispatcher.handle(message))
        expect(GameEngineService).to have_received(:create_by_word).with(realm, 'секрет')
      end
    end

    context 'when /level command received' do
      let!(:message) { build :message, :with_realm, text: '/level', realm: realm }
      let!(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

      it 'replies with prompt to submit game level' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
          expect(Telegram::TelegramMessenger).to have_received(:send_message).with(realm.channel, 'Select game level:', markup)
        }.not_to change(Game, :count)
      end
    end

    context 'when /level command received with selected level' do
      let!(:callback) { build :callback, :with_realm, data: '/level easy', realm: realm }

      before do
        allow(Telegram::TelegramMessenger).to receive(:answerCallbackQuery)
      end

      context 'being last command in command queue' do
        before do
          allow(Telegram::CommandQueue).to receive(:present?).and_return(false)
        end

        it 'creates setting with selected game level and response with inline message' do
          expect {
            expect(Telegram::TelegramDispatcher.handle_callback_query(callback)).to eq('Game level was set to easy.')
            expect(Telegram::TelegramMessenger).to have_received(:answerCallbackQuery)
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
            expect(Telegram::TelegramDispatcher.handle_callback_query(callback)).to be_nil
            expect(Telegram::TelegramMessenger).to have_received(:answerCallbackQuery).with(callback.id, 'Game level was set to easy.').once
          }.to change(Setting, :count).by(1)
        end
      end
    end

    context 'when /lang command received' do
      let!(:message) { build :message, :with_realm, text: '/lang', realm: realm }
      let!(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

      it 'replies with prompt to submit game language' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
          expect(Telegram::TelegramMessenger).to have_received(:send_message).with(realm.channel, 'Select game language:', markup)
        }.not_to change(Game, :count)
      end
    end

    context 'when /lang command received with selected language' do
      let!(:callback) { build :callback, :with_realm, data: '/lang RU', realm: realm }

      before do
        allow(Telegram::TelegramMessenger).to receive(:answerCallbackQuery)
      end

      context 'being last command in command queue' do
        before do
          allow(Telegram::CommandQueue).to receive(:present?).and_return(false)
        end

        it 'creates setting with selected game language and response with inline message' do
          expect {
            expect(Telegram::TelegramDispatcher.handle_callback_query(callback)).to eq('Language was set to Русский.')
            expect(Telegram::TelegramMessenger).to have_received(:answerCallbackQuery)
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
            expect(Telegram::TelegramDispatcher.handle_callback_query(callback)).to be_nil
            expect(Telegram::TelegramMessenger).to have_received(:answerCallbackQuery).with(callback.id, 'Language was set to Русский.').once
          }.to change(Setting, :count).by(1)
        end
      end
    end

    context 'when /tries command received' do
      let!(:message) { build :message, :with_realm, text: '/tries', realm: realm }
      let!(:payload) { OpenStruct.new(message: message) }

      before do
        allow(Telegram::Action::Tries).to receive(:execute)
      end

      it 'errors out with message about no recent games available' do
        expect {
          expect(Telegram::TelegramDispatcher.update(payload)).
              to have_attributes(text: match('No recent game to show _/tries_ guesses on.'))
          expect(Telegram::Action::Tries).not_to have_received(:execute)
        }.not_to change(Guess, :count)
      end

      it 'raises GameNotRunningException' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
        }.to raise_error(Errors::GameNotRunningException)
      end
    end

    context 'when /best command received' do
      let!(:message) { build :message, :with_realm, text: '/best', realm: realm }
      let!(:payload) { OpenStruct.new(message: message) }

      before do
        allow(Telegram::Action::Best).to receive(:execute)
      end

      it 'errors out with message about no recent games available' do
        expect {
          expect(Telegram::TelegramDispatcher.update(payload)).
              to have_attributes(text: match('No recent game to show _/best_ guesses on.'))
          expect(Telegram::Action::Best).not_to have_received(:execute)
        }.not_to change(Guess, :count)
      end

      it 'raises GameNotRunningException' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
        }.to raise_error(Errors::GameNotRunningException)
      end
    end

    context 'when /zero command received' do
      let!(:message) { build :message, :with_realm, text: '/zero', realm: realm }
      let!(:payload) { OpenStruct.new(message: message) }

      before do
        allow(Telegram::Action::Zero).to receive(:execute)
      end

      it 'errors out with message about no recent games available' do
        expect {
          expect(Telegram::TelegramDispatcher.update(payload)).
              to have_attributes(text: match('No recent game to show _/zero_ guesses on.'))
          expect(Telegram::Action::Zero).not_to have_received(:execute)
        }.not_to change(Guess, :count)
      end

      it 'raises GameNotRunningException' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
        }.to raise_error(Errors::GameNotRunningException)
      end
    end

    context 'when non command guess word received' do
      let!(:message) { build :message, :with_realm, text: 'secret', realm: realm }

      it 'ignores the message' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to be_nil
        }.not_to change(Guess, :count)
      end
    end
  end

  context 'when game has just started and had no guesses placed' do
    let!(:game) { create(:game, :realm, secret: 'secret', realm: realm, status: :created, dictionary: english) }

    context 'when /best command received' do
      let!(:message) { build :message, :with_realm, text: '/best', realm: realm }

      it 'replies with no guesses message' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to include('There was no guesses so far')
        }.not_to change(Guess, :count)
      end
    end

    context 'when /suggest command received' do
      let!(:message) { build :message, :with_realm, text: '/suggest', realm: realm }

      it 'suggests a word with matching number of letters' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to match('Suggestion: _\w{6}_')
        }.to change{ game.guesses.count }.by(1)
      end
    end

    context 'when /lang command received' do
      let!(:message) { build :message, :with_realm, text: '/lang', realm: realm }
      let!(:payload) { OpenStruct.new(message: message) }

      before do
        allow(Telegram::Action::Language).to receive(:execute)
      end

      it 'errors out with message about permissions' do
        expect {
          expect(Telegram::TelegramDispatcher.update(payload)).
              to have_attributes(text: match('You are NOT allowed to change game language.'))
          expect(Telegram::Action::Language).not_to have_received(:execute)
        }.not_to change(Game, :count)
      end

      it 'raises CommandNotPermitted' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
        }.to raise_error(Errors::CommandNotPermittedException)
      end
    end

    context 'when /level command received' do
      let!(:message) { build :message, :with_realm, text: '/level', realm: realm }
      let!(:payload) { OpenStruct.new(message: message) }

      before do
        allow(Telegram::Action::Level).to receive(:execute)
      end

      it 'errors out with message about permissions' do
        expect {
          expect(Telegram::TelegramDispatcher.update(payload)).
              to have_attributes(text: match('You are NOT allowed to change game level.'))
          expect(Telegram::Action::Level).not_to have_received(:execute)
        }.not_to change(Game, :count)
      end

      it 'raises CommandNotPermitted' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
        }.to raise_error(Errors::CommandNotPermittedException)
      end
    end

    context 'when voice guess received' do
      let!(:message) { build :message, :with_realm, :voice_short, realm: realm }

      before do
        allow(Telegram::TelegramMessenger).to receive(:loadFile).with(message.voice.file_id)
        allow(GoogleCloudService).to receive(:recognize).with(anything(), 'en-GB').and_return('wonder')
        allow(Telegram::Action::Guess).to receive(:execute)
      end

      it 'uses voice message transcribed word as a guess' do
        expect(Telegram::TelegramDispatcher.handle(message))
        expect(Telegram::Action::Guess).to have_received(:execute).with(realm.channel, realm.user, 'wonder')
      end
    end
  end

  context 'when game is in progress and has multiple guesses placed' do
    let!(:game) { create(:game, :realm, :with_tries, secret: 'secret', realm: realm,  status: :running, dictionary: english) }

    context 'when /guess command received with non-exact guess word' do
      let!(:message) { build :message, :with_realm, text: '/guess flight', realm: realm }

      it 'replies with guess result' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to include('Guess 11: _flight_')
          expect(game.reload.running?).to eq(true)
        }.to change(Guess, :count).by(1)
      end
    end

    context 'when /guess command received case sensitive guess word' do
      let!(:message) { build :message, :with_realm, text: '/guess Secret', realm: realm }

      it 'handles case sensitive case' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
          expect(game.reload.finished?).to eq(true)
        }.to change(Guess, :count).by(1)
      end
    end

    context 'when /guess command received with incorrect amount of letters in word' do
      let!(:message) { build :message, :with_realm, text: '/guess mistake', realm: realm }
      let!(:payload) { OpenStruct.new(message: message) }

      it 'replies with error message' do
        expect {
          expect(Telegram::TelegramDispatcher.update(payload)).
              to have_attributes(text: match('Your guess word _mistake_ (*7*) has to be *6* letters long.'))
        }.not_to change(Guess, :count)
      end

      it 'raises GuessException' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
        }.to raise_error(Errors::GuessException)
      end
    end

    context 'when /guess command received with exact guess word' do
      let!(:message) { build :message, :with_realm, text: '/guess secret', realm: realm }

      it 'replies with congratulations' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to include('Congratulations!')
          expect(game.reload.finished?).to eq(true)
        }.to change(Guess, :count).by(1)
      end
    end

    context 'when /guess command includes bot name received' do
      let!(:message) { build :message, :with_realm, text: '/guess@BullsAndCowsWordsBot secret', realm: realm }

      before do
        allow(GameEngineService).to receive(:guess)
        allow(Telegram::TelegramMessenger).to receive(:guess)
      end

      it 'handles bot name as optional part in command' do
        expect(Telegram::TelegramDispatcher.handle(message))
        expect(GameEngineService).to have_received(:guess).with(game, user, 'secret')
      end
    end

    context 'when /tries command received' do
      let!(:message) { build :message, :with_realm, text: '/tries', realm: realm }

      it 'replies previous guess tries' do
        expect(Telegram::TelegramDispatcher.handle(message)).to include('Try 9:')
      end

      context 'when /tries command includes bot name received' do
        let!(:message) { build :message, :with_realm, text: '/tries@BullsAndCowsWordsBot', realm: realm }

        before do
          allow(GameEngineService).to receive(:tries)
          allow(Telegram::TelegramMessenger).to receive(:tries)
        end

        it 'handles bot name as optional part in command' do
          expect(Telegram::TelegramDispatcher.handle(message))
          expect(GameEngineService).to have_received(:tries)
        end
      end
    end

    context 'when /best command received' do
      let!(:message) { build :message, :with_realm, text: '/best', realm: realm }

      it 'replies with top guesses' do
        expect {
          result = Telegram::TelegramDispatcher.handle(message)
          expect(result).to include('Top 1: *sector*, Bulls: *3*, Cows: *2*')
          expect(result).to include('Top 2: *master*, Bulls: *1*, Cows: *3*')
          expect(result).to include('Top 3: *energy*, Bulls: *1*, Cows: *2*')
          expect(result).to include('Top 4: *engine*, Bulls: *1*, Cows: *2*')
          expect(result).to include('Top 5: *staple*, Bulls: *1*, Cows: *2*')
        }.not_to change(Guess, :count)
      end
    end

    context 'when /best command received with a <limit>' do
      let!(:message) { build :message, :with_realm, text: '/best 3', realm: realm }

      it 'replies with top <limit> guesses' do
        expect {
          result = Telegram::TelegramDispatcher.handle(message)
          expect(result).to include('Top 1: *sector*, Bulls: *3*, Cows: *2*')
          expect(result).to include('Top 2: *master*, Bulls: *1*, Cows: *3*')
          expect(result).to include('Top 3: *energy*, Bulls: *1*, Cows: *2*')
          expect(result).not_to include('Top 4:')
        }.not_to change(Guess, :count)
      end
    end

    context 'when /best command includes bot name received' do
      let!(:message) { build :message, :with_realm, text: '/best@BullsAndCowsWordsBot', realm: realm }

      before do
        allow(GameEngineService).to receive(:best)
        allow(Telegram::TelegramMessenger).to receive(:best)
      end

      it 'handles bot name as optional part in command' do
        expect(Telegram::TelegramDispatcher.handle(message))
        expect(GameEngineService).to have_received(:best)
      end
    end

    context 'when /hint command received' do
      let!(:message) { build :message, :with_realm, text: '/hint', realm: realm }

      it 'reveals one letter in a secret' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to match(/Secret word has letter \*\w\* in it/)
        }.to change{ game.hints.count }.by(1)
      end
    end

    context 'when /hint command received with a <letter>' do
      context 'with a matching letter' do
        let!(:message) { build :message, :with_realm, text: '/hint c', realm: realm }

        it 'reveals specified matching letter in a secret' do
          expect {
            expect(Telegram::TelegramDispatcher.handle(message)).to match(/Secret word has letter \*c\* in it/)
          }.to change{ game.hints.count }.by(1)
        end
      end

      context 'with a letter that is not in secret word' do
        let!(:message) { build :message, :with_realm, text: '/hint x', realm: realm }

        it 'reveals the fact that the specified letter is NOT in a secret' do
          expect {
            expect(Telegram::TelegramDispatcher.handle(message)).to match(/Secret word has NO letter \*x\* in it/)
          }.to change{ game.hints.count }.by(1)
        end
      end
    end

    context 'when /hint command received with a <number>' do
      context 'with a matching letter' do
        let!(:message) { build :message, :with_realm, text: '/hint 2', realm: realm }

        it 'reveals specified number of letter in a secret' do
          expect {
            expect(Telegram::TelegramDispatcher.handle(message)).to match(/Secret word has letter \*e\* in it/)
          }.to change{ game.hints.count }.by(1)
        end
      end

      context 'with a number that is over the max number of letters' do
        let!(:message) { build :message, :with_realm, text: '/hint 7', realm: realm }

        xit 'raises error that number is out of bounds' do
          expect {
            Telegram::TelegramDispatcher.handle(message)
          }.to raise_error
        end
      end

      context 'given a game with a long secret word' do
        let!(:game_long_secret) { create(:game, :realm, secret: 'одновалентность', realm: realm, status: :running) }

        context 'with a number that is over 10 letters, but within word length' do
          let!(:message) { build :message, :with_realm, text: '/hint 14', realm: realm }

          it 'reveals specified number of letter in a secret' do
            expect {
              expect(Telegram::TelegramDispatcher.handle(message)).to match(/Secret word has letter \*т\* in it/)
            }.to change{ game_long_secret.hints.count }.by(1)
          end
        end
      end
    end

    context 'when /suggest <letters> command received with letters matching available suggestion' do
      let!(:message) { build :message, :with_realm, text: '/suggest re', realm: realm }

      it 'suggests a word with a substring specified' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to include('Suggestion: _barrel_, *Bulls: 2*, *Cows: 0*.')
        }.to change{ game.guesses.count }.by(1)
      end
    end

    context 'when /suggest <letters> command received not matching any suggestions' do
      let!(:message) { build :message, :with_realm, text: '/suggest ku', realm: realm }

      it 'finds no words to suggests based on a substring specified' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to include('Could not find any suggestions based on provided word letters _ku_')
        }.not_to change{ game.guesses.count }
      end
    end

    context 'when /zero command received' do
      let!(:message) { build :message, :with_realm, text: '/zero', realm: realm }

      it 'replies with guesses where bulls and cows have zero occurrences' do
        expect {
          result = Telegram::TelegramDispatcher.handle(message)
          expect(result).to include('Zero letters in: *ballad*, Bulls: *0*, Cows: *0*.')
          expect(result).to include('Zero letters in: *quorum*, Bulls: *0*, Cows: *0*.')
        }.not_to change(Guess, :count)
      end
    end

    context 'when /stop command received' do
      let!(:message) { build :message, :with_realm, :group, text: '/stop', realm: realm }

      context 'when /stop command is permitted' do
        before do
          allow(Telegram::Validator).to receive(:permitted?).and_return(true)
        end

        it 'finishes the game, replies with a secret word' do
          expect {
            expect(Telegram::TelegramDispatcher.handle(message)).to include('You give up? Here is the secret word *secret*.')
          }.to change{ game.reload.status }.to('aborted')
        end
      end

      context 'when /stop command is NOT permitted' do
        let!(:payload) { OpenStruct.new(message: message) }

        before do
          allow(Telegram::Validator).to receive(:permitted?).and_return(false)
        end

        it 'fails to stop the game, replies with a error message' do
          expect {
            expect(Telegram::TelegramDispatcher.update(payload)).
                to have_attributes(text: match('You are NOT allowed to _/stop_ this game.'))
          }.not_to change{ game.reload.status }
        end

        it 'raises CommandNotPermitted' do
          expect {
            Telegram::TelegramDispatcher.handle(message)
          }.to raise_error(Errors::CommandNotPermittedException)
        end
      end
    end

    context 'when /stop command includes bot name received' do
      let!(:message) { build :message, :with_realm, :group, text: '/stop@BullsAndCowsWordsBot', realm: realm }

      before do
        allow(Telegram::Validator).to receive(:permitted?).and_return(true)
        allow(GameService).to receive(:stop!)
      end

      it 'handles bot name as optional part in command' do
        expect(Telegram::TelegramDispatcher.handle(message))
        expect(GameService).to have_received(:stop!).with(game)
      end
    end

    context 'when non command word received with non-exact guess' do
      let!(:message) { build :message, :with_realm, text: 'flight', realm: realm }

      it 'replies with guess result' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to include('Guess 11: _flight_')
          expect(game.reload.running?).to eq(true)
        }.to change(Guess, :count).by(1)
      end
    end

    context 'when non command word is received with exact guess' do
      let!(:message) { build :message, :with_realm, text: 'secret', realm: realm }

      it 'replies with congratulations' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to include('Congratulations!')
          expect(game.reload.finished?).to eq(true)
        }.to change(Guess, :count).by(1)
      end
    end

    context 'when non command multiple words is received' do
      let!(:message) { build :message, :with_realm, text: 'hello world', realm: realm }

      it 'ignore the message' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
        }.not_to change(Guess, :count)
      end
    end

    context 'when multiline non command words is received' do
      let!(:message) { build :message, :with_realm, text: "line\nanother line\nthird", realm: realm }

      it 'ignore the message' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to be_nil
        }.not_to change(Guess, :count)
      end
    end
  end

  context 'with russian secret word game in progress' do
    let!(:game) { create(:game, :realm, secret: 'привет', realm: realm,  status: :running, dictionary: russian) }

    context 'when /guess command received case sensitive unicode guess word' do
      let!(:privet) { create(:noun, noun: 'привет')}

      let!(:message) { build :message, :with_realm, text: '/guess Привет', realm: realm }

      it 'handles case sensitive unicode case' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
          expect(game.reload.finished?).to eq(true)
        }.to change(Guess, :count).by(1)
      end
    end
  end

  context 'when game has finished' do
    let!(:game) { create(:finished_game, :realm, :with_tries, secret: 'secret', realm: realm, winner_id: user.id) }

    context 'when /guess command received' do
      let!(:message) { build :message, :with_realm, text: '/guess secret', realm: realm }
      let!(:payload) { OpenStruct.new(message: message) }

      it 'replies with error message' do
        expect {
          expect(Telegram::TelegramDispatcher.update(payload)).
              to have_attributes(text: match('Game is not running. Please _/start_ new game and try again.'))
        }.not_to change(Guess, :count)
      end

      it 'raises GameNotRunningException' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
        }.to raise_error(Errors::GameNotRunningException)
      end
    end

    context 'when /hint command received' do
      let!(:message) { build :message, :with_realm, text: '/hint', realm: realm }
      let!(:payload) { OpenStruct.new(message: message) }

      it 'replies with error message' do
        expect {
          expect(Telegram::TelegramDispatcher.update(payload)).
              to have_attributes(text: match('Game is not running. Please _/start_ new game and try again.'))
        }.not_to change(Hint, :count)
      end

      it 'raises GameNotRunningException' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
        }.to raise_error(Errors::GameNotRunningException)
      end
    end

    context 'when /suggest command received' do
      let!(:message) { build :message, :with_realm, text: '/suggest', realm: realm }
      let!(:payload) { OpenStruct.new(message: message) }

      it 'replies with error message' do
        expect {
          expect(Telegram::TelegramDispatcher.update(payload)).
              to have_attributes(text: 'Game is not running. Please _/start_ new game and try again.')
        }.not_to change(Hint, :count)
      end

      it 'raises GameNotRunningException' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
        }.to raise_error(Errors::GameNotRunningException)
      end
    end

    context 'when /level command received' do
      let!(:message) { build :message, :with_realm, text: '/level', realm: realm }
      let(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

      it 'replies with prompt to submit game level' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
          expect(Telegram::TelegramMessenger).to have_received(:send_message).with(realm.channel, 'Select game level:', markup)
        }.not_to change(Game, :count)
      end
    end

    context 'when /level command received with selected level' do
      let!(:callback) { build :callback, :with_realm, data: '/level easy', realm: realm }

      before do
        allow(Telegram::TelegramMessenger).to receive(:answerCallbackQuery)
      end

      context 'being last command in command queue' do
        before do
          allow(Telegram::CommandQueue).to receive(:present?).and_return(false)
        end

        it 'creates setting with selected game level and response with inline message' do
          expect {
            expect(Telegram::TelegramDispatcher.handle_callback_query(callback)).to eq('Game level was set to easy.')
            expect(Telegram::TelegramMessenger).to have_received(:answerCallbackQuery)
          }.to change(Setting, :count).by(1)
        end
      end
    end

    context 'when /lang command received' do
      let!(:message) { build :message, :with_realm, text: '/lang', realm: realm }
      let(:markup) { instance_of(Telegram::Bot::Types::InlineKeyboardMarkup) }

      it 'replies with prompt to submit game language' do
        expect {
          Telegram::TelegramDispatcher.handle(message)
          expect(Telegram::TelegramMessenger).to have_received(:send_message).with(realm.channel, 'Select game language:', markup)
        }.not_to change(Game, :count)
      end
    end

    context 'when /lang command received with selected language' do
      let!(:callback) { build :callback, :with_realm, data: '/lang RU', realm: realm }

      before do
        allow(Telegram::TelegramMessenger).to receive(:answerCallbackQuery)
      end

      context 'being last command in command queue' do
        before do
          allow(Telegram::CommandQueue).to receive(:present?).and_return(false)
        end

        it 'creates setting with selected game language and response with inline message' do
          expect {
            expect(Telegram::TelegramDispatcher.handle_callback_query(callback)).to eq('Language was set to Русский.')
            expect(Telegram::TelegramMessenger).to have_received(:answerCallbackQuery)
          }.to change(Setting, :count).by(1)
        end
      end
    end

    context 'when /tries command received' do
      let!(:message) { build :message, :with_realm, text: '/tries', realm: realm }

      it 'replies with game guesses' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to match('Try .* Bulls: .* Cows: .*')
        }.not_to change(Guess, :count)
      end
    end

    context 'when /best command received' do
      let!(:message) { build :message, :with_realm, text: '/best', realm: realm }

      it 'replies with top guesses' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to match('Top .* Bulls: .* Cows: .*')
        }.not_to change(Guess, :count)
      end
    end

    context 'when /zero command received' do
      let!(:message) { build :message, :with_realm, text: '/zero', realm: realm }

      it 'replies with guesses where bulls and cows have zero occurrences' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to match('Zero letters in:')
        }.not_to change(Guess, :count)
      end
    end

    context 'when /score command received' do
      let!(:message) { build :message, :with_realm, text: '/score', realm: realm }
      let!(:score) { create(:score, total: 807, winner_id: user.ext_id, channel: realm.channel, created_at: 1.second.ago) }

      it 'replies with top scores' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to satisfy { |response|
            response.first.include?('1: <b>John Smith</b>, User: <i>john_smith</i>, Score: <b>807</b>') &&
                response.last == 'HTML'
          }
        }.not_to change{ game.reload.score }
      end
    end

    context 'when /trend command received' do
      let!(:message) { build :message, :with_realm, text: '/trend', realm: realm }
      let!(:score1) { create(:score, total: 807, winner_id: user.ext_id, channel: realm.channel, created_at: 15.minutes.ago) }
      let!(:score2) { create(:score, total: 960, winner_id: user.ext_id, channel: realm.channel, created_at: 5.minutes.ago) }

      it 'replies with top players' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to satisfy { |response|
            response.first.include?('1: <b>John Smith</b>, User: <i>john_smith</i>, Score: <b>153</b>') &&
                response.last == 'HTML'
          }
        }.not_to change{ game.reload.score }
      end
    end

    context 'when non command guess word received' do
      let!(:message) { build :message, :with_realm, text: 'secret', realm: realm }

      it 'ignores the message' do
        expect {
          expect(Telegram::TelegramDispatcher.handle(message)).to be_nil
          expect(game.reload.finished?).to eq(true)
        }.not_to change(Guess, :count)
      end
    end
  end

  context 'when /help command received' do
    let!(:message) { build :message, :with_realm, text: '/help', realm: realm }

    it 'replies with help message' do
      expect(Telegram::TelegramDispatcher.handle(message)).to include('Here is the list of available commands:')
    end

    context 'when /help command includes bot name received' do
      let!(:message) { build :message, :with_realm, text: '/help@BullsAndCowsWordsBot', realm: realm }

      before do
        allow(Telegram::TelegramMessenger).to receive(:help)
      end

      it 'handles bot name as optional part in command' do
        expect(Telegram::TelegramDispatcher.handle(message))
        expect(Telegram::TelegramMessenger).to have_received(:help)
      end
    end
  end

  context 'when /unknown command received' do
    let!(:message) { build :message, :with_realm, text: '/unknown', realm: realm }

    it 'replies with generic message' do
      expect(Telegram::TelegramDispatcher.handle(message)).to include('Nothing I can do')
    end
  end

  context 'when /rules command received' do
    let!(:message) { build :message, :with_realm, text: '/rules', realm: realm }

    before do
      allow(Telegram::TelegramMessenger).to receive(:rules)
    end

    it 'handles bot name as optional part in command' do
      expect(Telegram::TelegramDispatcher.handle(message))
      expect(Telegram::TelegramMessenger).to have_received(:rules)
    end
  end

end

