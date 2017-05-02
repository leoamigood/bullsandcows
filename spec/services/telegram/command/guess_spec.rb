require 'rails_helper'

describe Telegram::Action::Guess, type: :service do
  let!(:user) { create :user, :telegram, :john_smith }
  let!(:realm) { build :telegram_realm, user: user }

  let!(:message) { build :message, :with_realm, text: 'hostel', realm: realm }

  let!(:game) { create(:game, :telegram, secret: 'secret', channel: realm.channel) }

  context 'given created game' do
    before do
      allow(GameService).to receive(:recent_game).and_return(game)
      EventSubscriptions.subscribe
      allow(TelegramMessenger).to receive(:guess)
    end

    it 'verifies non exact guess execution chain' do
      expect {
        Telegram::Action::Guess.execute(realm.channel, user, message.text)
      }.not_to change{ game.reload.winner_id }

      expect(TelegramMessenger).to have_received(:guess).with(
          have_attributes(game_id: game.id, word: 'hostel', username: 'john_smith')
      )
    end

    context 'with exact guess' do
      before do
        message.text = 'secret'
      end

      it 'verifies winning guess execution chain' do
        expect {
          Telegram::Action::Guess.execute(realm.channel, user, message.text)
        }.to change{ game.reload.winner_id.to_s }.from('').to(user.ext_id)
      end
    end
  end
end
