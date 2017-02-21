require 'rails_helper'

describe Telegram::Validator, type: :service do
  let!(:channel) { Random.rand(@MAX_INT_VALUE) }

  let!(:creator) { User.new(id = Random.rand(@MAX_INT_VALUE), username = '@NYCTrooper') }
  let!(:player) { User.new(id = Random.rand(@MAX_INT_VALUE), username = '@Amig0') }

  let!(:realm) { build :realm, :telegram, channel: channel, user_id: creator.id }

  context 'given running game' do
    let!(:game) { create(:game, :realm, :running, realm: realm) }

    context 'given direct chat message' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/stop') }

      before do
        TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('member')

        message.stub_chain(:chat, :type).and_return('individual')
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(creator.id)
      end

      it 'verifies player permissions to stop the game' do
        expect(Telegram::Validator.permitted?(game, :stop, message)).to be true
      end
    end

    context 'given group chat message' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/stop') }

      before do
        message.stub_chain(:chat, :type).and_return('group')
      end

      context 'given message from a channel creator' do
        before do
          TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('creator')

          message.stub_chain(:chat, :id).and_return(channel)
          message.stub_chain(:from, :id).and_return(creator.id)
        end

        it 'verifies permissions to stop the game' do
          expect(Telegram::Validator.permitted?(game, :stop, message)).to be true
        end
      end

      context 'given message from a channel administrator' do
        before do
          TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('administrator')

          message.stub_chain(:chat, :id).and_return(channel)
          message.stub_chain(:from, :id).and_return(creator.id)
        end

        it 'verifies permissions to stop the game' do
          expect(Telegram::Validator.permitted?(game, :stop, message)).to be true
        end
      end

      context 'given message from a game creator' do
        before do
          TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('member')

          message.stub_chain(:chat, :id).and_return(channel)
          message.stub_chain(:from, :id).and_return(creator.id)
        end

        it 'verifies permissions to stop the game' do
          expect(Telegram::Validator.permitted?(game, :stop, message)).to be true
        end
      end

      context 'given message from a game player' do
        before do
          TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('member')

          message.stub_chain(:chat, :id).and_return(channel)
          message.stub_chain(:from, :id).and_return(player.id)
        end

        it 'verifies permissions absence to stop the game' do
          expect(Telegram::Validator.permitted?(game, :stop, message)).to be false
        end
      end
    end
  end

end
