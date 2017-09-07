require 'rails_helper'
include Telegram::Action::Command

describe Telegram::Validator, type: :service do
  let!(:channel) { Random.rand(@MAX_INT_VALUE) }

  let!(:creator) { create :user, :telegram, :john_smith }
  let!(:player)  { create :user, :telegram, :josef_gold }

  let!(:creator_realm) { build :telegram_realm, channel: channel, user: creator }
  let!(:player_realm) { build :telegram_realm, channel: channel, user: player }

  context 'given a running game for the channel' do
    let!(:game) { create(:game, :realm, :running, realm: creator_realm) }

    context 'given direct /start message' do
      let!(:message) { build :message, :with_realm, text: '/create', realm: creator_realm }

      it 'denies player permissions to restart the game' do
        expect{
          Telegram::Validator.validate!(START, channel, message)
        }.to raise_error(Errors::CommandNotPermittedException)
      end
    end

    context 'given group /start message' do
      let!(:message) { build :message, :with_realm, :group, text: '/create', realm: creator_realm }

      it 'denies player permission to restart the game' do
        expect{
          Telegram::Validator.validate!(START, channel, message)
        }.to raise_error(Errors::CommandNotPermittedException)
      end
    end

    context 'given direct /stop message' do
      let!(:message) { build :message, :with_realm, :private, text: '/stop', realm: creator_realm }

      before do
        Telegram::TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('member')
      end

      it 'allows player permission to stop the game' do
        expect{
          Telegram::Validator.validate!(STOP, channel, message)
        }.not_to raise_error
      end
    end

    context 'given group /stop message' do
      let!(:message) { build :message, :with_realm, :group, text: '/stop', realm: creator_realm }

      context 'given message from a channel creator' do
        before do
          Telegram::TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('creator')
        end

        it 'allows player permission to stop the game' do
          expect{
            Telegram::Validator.validate!(Telegram::Action::Stop, channel, message)
          }.not_to raise_error
        end
      end

      context 'given message from a channel administrator' do
        before do
          Telegram::TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('administrator')
        end

        it 'allows player permission to stop the game' do
          expect{
            Telegram::Validator.validate!(STOP, channel, message)
          }.not_to raise_error
        end
      end

      context 'given message from a game creator' do
        before do
          Telegram::TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('member')
        end

        it 'allows player permission to stop the game' do
          expect{
            Telegram::Validator.validate!(STOP, channel, message)
          }.not_to raise_error
        end
      end

      context 'given message from a game player' do
        before do
          Telegram::TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('member')
        end

        let!(:message) { build :message, :with_realm, :group, text: '/stop', realm: player_realm }

        it 'denies player permission to stop the game' do
          expect{
            Telegram::Validator.validate!(STOP, channel, message)
          }.to raise_error(Errors::CommandNotPermittedException)
        end
      end
    end

    context 'given super group /stop message' do
      let!(:message) { build :message, :with_realm, :supergroup, text: '/stop', realm: creator_realm }

      context 'given message from a channel creator' do
        before do
          Telegram::TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('creator')
        end

        it 'allows player permission to stop the game' do
          expect{
            Telegram::Validator.validate!(Telegram::Action::Stop, channel, message)
          }.not_to raise_error
        end
      end

      context 'given message from a channel administrator' do
        before do
          Telegram::TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('administrator')
        end

        it 'allows player permission to stop the game' do
          expect{
            Telegram::Validator.validate!(STOP, channel, message)
          }.not_to raise_error
        end
      end

      context 'given message from a game creator' do
        before do
          Telegram::TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('member')
        end

        it 'allows player permission to stop the game' do
          expect{
            Telegram::Validator.validate!(STOP, channel, message)
          }.not_to raise_error
        end
      end

      context 'given message from a game player' do
        before do
          Telegram::TelegramMessenger.stub_chain(:getChatMember, :[], :[]).with('result').with('status').and_return('member')
        end

        let!(:message) { build :message, :with_realm, :group, text: '/stop', realm: player_realm }

        it 'denies player permission to stop the game' do
          expect{
            Telegram::Validator.validate!(STOP, channel, message)
          }.to raise_error(Errors::CommandNotPermittedException)
        end
      end
    end
  end

end
