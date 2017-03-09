require 'rails_helper'

describe Telegram::Action::Guess, type: :service do
  let!(:user) { User.new(id = Random.rand, name = '@Amig0') }
  let!(:channel) { 'telegram-game-channel' }

  let!(:game) { create(:game, source: :telegram, secret: 'secret', channel: channel) }

  context 'given created game' do
    let!(:message) { Telegram::Bot::Types::Message.new(text: 'hostel') }

    before do
      allow(GameService).to receive(:recent_game).and_return(game)

      message.stub_chain(:chat, :id).and_return(channel)
      message.stub_chain(:from, :id).and_return(user.id)
      message.stub_chain(:from, :username).and_return(user.name)

      allow(TelegramMessenger).to receive(:guess)
    end

    it 'verifies guess execution chain' do
      Telegram::Action::Guess.execute(channel, message, message.text)

      expect(TelegramMessenger).to have_received(:guess).with(
          have_attributes(game_id: game.id, word: 'hostel', username: '@Amig0')
      )
    end
  end
end
