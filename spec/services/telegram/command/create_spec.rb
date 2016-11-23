require 'rails_helper'

describe Telegram::Command::Create, type: :service do
  context 'given game channel and settings' do
    let!(:channel) { 'telegram-game-channel' }
    let!(:settings) { create :setting, channel: channel, complexity: 'hard', language: 'RU'}

    before do
      allow(Telegram::CommandQueue).to receive(:clear)
      allow(TelegramMessenger).to receive(:game_created)
    end

    it 'verifies create by word execution chain' do
      Telegram::Command::Create.execute(channel, 'secret', 'create_by_word')

      expect(Telegram::CommandQueue).to have_received(:clear).with(no_args)
      expect(TelegramMessenger).to have_received(:game_created).with(
          have_attributes(status: 'created', secret: 'secret')
      )
    end

    context 'with a dictionary' do
      let!(:dictionary) { create :dictionary, :words_with_levels, lang: 'RU' }

      it 'verifies create by number execution chain' do
        Telegram::Command::Create.execute(channel, 5, 'create_by_number')

        expect(Telegram::CommandQueue).to have_received(:clear).with(no_args)
        expect(TelegramMessenger).to have_received(:game_created).with(
            have_attributes(status: 'created').and have_attributes(secret: satisfy{ |s| s.length == 5 })
        )
      end
    end
  end
end
