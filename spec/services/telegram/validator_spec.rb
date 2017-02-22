require 'rails_helper'
include Telegram::Command::Action

describe Telegram::Validator, type: :service do
  let!(:channel) { Random.rand(@MAX_INT_VALUE) }

  let!(:creator) { User.new(id = Random.rand(@MAX_INT_VALUE), username = '@NYCTrooper') }
  let!(:player) { User.new(id = Random.rand(@MAX_INT_VALUE), username = '@Amig0') }

  let!(:realm) { build :realm, :telegram, channel: channel, user_id: creator.id }

  context 'given a running game for the channel' do
    let!(:game) { create(:game, :realm, :running, realm: realm) }

    context 'given direct /start message' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/start') }

      before do
        message.stub_chain(:chat, :id).and_return(channel)
      end

      it 'denies player permissions to restart the game' do
        expect{
          Telegram::Validator.validate!(START, realm.channel, message)
        }.to raise_error(Errors::CommandNotPermittedException)
      end
    end

    context 'given group /start message' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/start') }

      before do
        message.stub_chain(:chat, :type).and_return('group')
      end

      it 'denies player permission to restart the game' do
        expect{
          Telegram::Validator.validate!(START, realm.channel, message)
        }.to raise_error(Errors::CommandNotPermittedException)
      end
    end

    context 'given direct /stop message' do
      let!(:message) { Telegram::Bot::Types::Message.new(text: '/stop') }

      before do
        TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('member')

        message.stub_chain(:chat, :type).and_return('individual')
        message.stub_chain(:chat, :id).and_return(channel)
        message.stub_chain(:from, :id).and_return(creator.id)
      end

      it 'allows player permission to stop the game' do
        expect{
          Telegram::Validator.validate!(STOP, realm.channel, message)
        }.not_to raise_error
      end
    end

    context 'given group /stop message' do
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

        it 'allows player permission to stop the game' do
          expect{
            Telegram::Validator.validate!(Telegram::Command::Stop, realm.channel, message)
          }.not_to raise_error
        end
      end

      context 'given message from a channel administrator' do
        before do
          TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('administrator')

          message.stub_chain(:chat, :id).and_return(channel)
          message.stub_chain(:from, :id).and_return(creator.id)
        end

        it 'allows player permission to stop the game' do
          expect{
            Telegram::Validator.validate!(STOP, realm.channel, message)
          }.not_to raise_error
        end
      end

      context 'given message from a game creator' do
        before do
          TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('member')

          message.stub_chain(:chat, :id).and_return(channel)
          message.stub_chain(:from, :id).and_return(creator.id)
        end

        it 'allows player permission to stop the game' do
          expect{
            Telegram::Validator.validate!(STOP, realm.channel, message)
          }.not_to raise_error
        end
      end

      context 'given message from a game player' do
        before do
          TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('member')

          message.stub_chain(:chat, :id).and_return(channel)
          message.stub_chain(:from, :id).and_return(player.id)
        end

        it 'denies player permission to stop the game' do
          expect{
            Telegram::Validator.validate!(STOP, realm.channel, message)
          }.to raise_error(Errors::CommandNotPermittedException)
        end
      end
    end
  end

end
