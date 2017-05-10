require 'rails_helper'

describe Telegram::Action::Create, type: :service do
  let!(:user) { create :user, :telegram, :john_smith }
  let!(:realm) { build :telegram_realm, user: user }

  let!(:message) { build :message, :with_realm, text: '/create', realm: realm }

  before do
    allow_any_instance_of(Telegram::CommandQueue::Queue).to receive(:pop)
  end

  context 'given game channel and settings' do
    let!(:settings) { create :setting, channel: realm.channel, complexity: 'hard', language: 'RU'}

    before do
      allow(TelegramMessenger).to receive(:game_created)
    end

    it 'verifies create by word execution chain' do
      expect_any_instance_of(Telegram::CommandQueue::Queue).to receive(:pop).with(no_args)
      Telegram::Action::Create.execute(realm.channel, user, word: 'secret', strategy: :by_word)

      expect(TelegramMessenger).to have_received(:game_created).with(
          have_attributes(status: 'created', secret: 'secret')
      )
    end

    context 'with a dictionary' do
      let!(:dictionary) { create :dictionary, :russian }
      let!(:hard) { create :dictionary_level, :hard_ru, dictionary_id: dictionary.id }

      it 'creates game with specifies word length' do
        expect_any_instance_of(Telegram::CommandQueue::Queue).to receive(:pop).with(no_args)
        Telegram::Action::Create.execute(realm.channel, user, length: 8, strategy: :by_number)

        expect(TelegramMessenger).to have_received(:game_created).with(
            have_attributes(status: 'created').and have_attributes(secret: satisfy{ |s| s.length == 8 })
        )
      end
    end
  end
end
