require 'rails_helper'

describe Telegram::Validator, type: :service do

  let!(:actor) { Telegram::Bot::Types::User.new() }
  let!(:message) { Telegram::Bot::Types::Message.new(text: '/stop') }

  before do
    allow(TelegramMessenger).to receive(:getChatMember).and_return(actor)

    message.stub_chain(:chat, :id)
    message.stub_chain(:from, :id)
  end

  context 'given direct chat message' do
    before do
      message.stub_chain(:chat, :type).and_return('individual')
      actor.stub_chain(:[], :[]).with('result').with('status').and_return('member')
    end

    it 'verifies player permissions to stop the game' do
      expect(Telegram::Validator.permitted?(:stop, message)).to be true
    end
  end

  context 'given group chat message' do
    before do
      message.stub_chain(:chat, :type).and_return('group')
    end

    context 'given message from a channel creator' do
      before do
        actor.stub_chain(:[], :[]).with('result').with('status').and_return('creator')
      end

      it 'verifies permissions to stop the game' do
        expect(Telegram::Validator.permitted?(:stop, message)).to be true
      end
    end

    context 'given message from a channel administrator' do
      before do
        actor.stub_chain(:[], :[]).with('result').with('status').and_return('administrator')
      end

      it 'verifies permissions to stop the game' do
        expect(Telegram::Validator.permitted?(:stop, message)).to be true
      end
    end

    context 'given message from a game creator' do
      before do
        actor.stub_chain(:[], :[]).with('result').with('status').and_return('member')
      end

      xit 'verifies permissions to stop the game' do
        expect(Telegram::Validator.permitted?(:stop, message)).to be true
      end
    end

    context 'given message from a game player' do
      before do
        actor.stub_chain(:[], :[]).with('result').with('status').and_return('member')
      end

      it 'verifies permissions absence to stop the game' do
        expect(Telegram::Validator.permitted?(:stop, message)).to be false
      end
    end
  end

end
