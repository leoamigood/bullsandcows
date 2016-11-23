require 'rails_helper'

describe Telegram::Command::Hint, type: :service do
  context 'given created game' do
    let!(:channel) { 'telegram-game-channel' }
    let!(:game) { create(:game, :telegram, secret: 'secret', channel: channel) }

    let!(:letter) { 'r' }

    before do
      allow(GameService).to receive(:find_by_channel!).and_return(game)
      allow(TelegramMessenger).to receive(:hint)
    end

    it 'verifies hint execution chain' do
      Telegram::Command::Hint.execute(channel, letter)

      expect(GameService).to have_received(:find_by_channel!).with(channel)
      expect(TelegramMessenger).to have_received(:hint).with(letter)
    end
  end
end
