require 'rails_helper'

describe Telegram::Command::Hint, type: :service do
  context 'given created game' do
    let!(:channel) { 'telegram-game-channel' }
    let!(:game) { create(:game, :telegram, secret: 'secret', channel: channel) }


    before do
      allow(GameService).to receive(:find_by_channel!).and_return(game)
      allow(TelegramMessenger).to receive(:hint)
    end

    let!(:letter) { 'r' }
    it 'verifies hint by letter execution chain' do
      Telegram::Command::Hint.execute_by_letter(channel, 'r')

      expect(GameService).to have_received(:find_by_channel!).with(channel)
      expect(TelegramMessenger).to have_received(:hint).with(letter)
    end

    let!(:number) { 4 }
    it 'verifies hint by number execution chain' do
      Telegram::Command::Hint.execute_by_number(channel, number)

      expect(GameService).to have_received(:find_by_channel!).with(channel)
      expect(TelegramMessenger).to have_received(:hint).with(letter)
    end
  end
end
