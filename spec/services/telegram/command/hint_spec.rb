require 'rails_helper'

describe Telegram::Action::Hint, type: :service do
  let!(:channel) { Random.rand(@MAX_INT_VALUE) }
  let!(:user) { build :user, id: Random.rand(@MAX_INT_VALUE), name: '@Amig0' }

  let!(:realm) { build :realm, :telegram, channel: channel, user_id: user.id }

  context 'given created game' do
    let!(:game) { create(:game, :realm, secret: 'secret', realm: realm) }

    before do
      allow(GameService).to receive(:find_by_channel!).and_return(game)
      allow(TelegramMessenger).to receive(:hint)
    end

    let!(:letter) { 'r' }
    it 'verifies hint by letter execution chain' do
      Telegram::Action::Hint.execute(channel, letter: 'r', strategy: :by_letter)

      expect(GameService).to have_received(:find_by_channel!).with(channel)
      expect(TelegramMessenger).to have_received(:hint).with(letter)
    end

    let!(:number) { 4 }
    it 'verifies hint by number execution chain' do
      Telegram::Action::Hint.execute(channel, number: number, strategy: :by_number)

      expect(GameService).to have_received(:find_by_channel!).with(channel)
      expect(TelegramMessenger).to have_received(:hint).with(letter)
    end
  end
end
