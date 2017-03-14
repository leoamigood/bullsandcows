require 'rails_helper'

describe Telegram::Action::Create, type: :service do
  let!(:channel) { Random.rand(@MAX_INT_VALUE) }
  let!(:user) { User.new(id = Random.rand(@MAX_INT_VALUE), name = '@Amig0') }

  let!(:message) { Telegram::Bot::Types::Message.new(text: '/create') }

  before do
    allow_any_instance_of(Telegram::CommandQueue::Queue).to receive(:pop)

    message.stub_chain(:chat, :id).and_return(channel)
    message.stub_chain(:from, :id).and_return(user.id)
  end

  context 'given game channel and settings' do
    let!(:settings) { create :setting, channel: channel, complexity: 'hard', language: 'RU'}

    before do
      allow(TelegramMessenger).to receive(:game_created)
    end

    it 'verifies create by word execution chain' do
      expect_any_instance_of(Telegram::CommandQueue::Queue).to receive(:pop).with(no_args)
      Telegram::Action::Create.execute(channel, message, word: 'secret', strategy: :by_word)

      expect(TelegramMessenger).to have_received(:game_created).with(
          have_attributes(status: 'created', secret: 'secret')
      )
    end

    context 'with a dictionary' do
      let!(:dictionary) { create :dictionary, :russian }
      let!(:hard) { create :dictionary_level, :hard_ru }

      it 'creates game with specifies word length' do
        expect_any_instance_of(Telegram::CommandQueue::Queue).to receive(:pop).with(no_args)
        Telegram::Action::Create.execute(channel, message, length: 8, strategy: :by_number)

        expect(TelegramMessenger).to have_received(:game_created).with(
            have_attributes(status: 'created').and have_attributes(secret: satisfy{ |s| s.length == 8 })
        )
      end
    end
  end
end
