require 'rails_helper'

describe Telegram::Command::Guess, type: :service do
  context 'given created game' do
    let!(:user) { '@Amig0' }
    let!(:channel) { 'telegram-game-channel' }

    let!(:game) { create(:game, :telegram, secret: 'secret', channel: channel) }

    let!(:message) { Telegram::Bot::Types::Message.new(text: 'hostel') }

    before do
      allow(GameService).to receive(:find_by_channel!).and_return(game)

      message.stub_chain(:chat, :id).and_return(channel)
      message.stub_chain(:from, :username).and_return(user)

      allow(TelegramMessenger).to receive(:guess)
    end

    it 'verifies guess execution chain' do
      Telegram::Command::Guess.execute(channel, message, message.text)

      expect(GameService).to have_received(:find_by_channel!).with(channel)
      expect(TelegramMessenger).to have_received(:guess).with(
          have_attributes(game_id: game.id, word: 'hostel', username: '@Amig0')
      )
    end
  end
end