require 'rails_helper'

describe Telegram::Action::Guess, type: :service do
  let!(:user) { create :user, username: '@Amig0' }
  let!(:channel) { 'telegram-game-channel' }

  let!(:realm) { build :realm, :telegram, channel: channel, user_id: user.ext_id }

  let!(:message) { build :message, :with_realm, text: 'hostel', realm: realm }

  let!(:game) { create(:game, source: :telegram, secret: 'secret', channel: channel) }

  context 'given created game' do
    before do
      allow(GameService).to receive(:recent_game).and_return(game)
      EventSubscriptions.subscribe
      allow(TelegramMessenger).to receive(:guess)
    end

    it 'verifies non exact guess execution chain' do
      expect {
        Telegram::Action::Guess.execute(channel, user, message.text)
      }.not_to change{ game.reload.winner_id }

      expect(TelegramMessenger).to have_received(:guess).with(
          have_attributes(game_id: game.id, word: 'hostel', username: '@Amig0')
      )
    end

    context 'with exact guess' do
      before do
        message.text = 'secret'
      end

      it 'verifies winning guess execution chain' do
        expect {
          Telegram::Action::Guess.execute(channel, user, message.text)
        }.to change{ game.reload.winner_id }.from(nil).to(user.ext_id)
      end
    end
  end
end
