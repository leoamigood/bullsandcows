require 'rails_helper'

describe Telegram::Action::Guess, type: :service do
  let!(:user) { build :user, id: Random.rand(@MAX_INT_VALUE), name: '@Amig0' }
  let!(:channel) { 'telegram-game-channel' }

  let!(:game) { create(:game, source: :telegram, secret: 'secret', channel: channel) }

  context 'given created game' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: 'hostel') }

    before do
      allow(GameService).to receive(:recent_game).and_return(game)

      message.stub_chain(:chat, :id).and_return(channel)
      message.stub_chain(:from, :id).and_return(user.id)
      message.stub_chain(:from, :username).and_return(user.name)

      EventSubscriptions.subscribe

      allow(TelegramMessenger).to receive(:guess)
    end

    it 'verifies non exact guess execution chain' do
      expect {
        Telegram::Action::Guess.execute(channel, message, message.text)
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
          Telegram::Action::Guess.execute(channel, message, message.text)
        }.to change{ game.reload.winner_id }.from(nil).to(user.id)
      end
    end
  end
end
