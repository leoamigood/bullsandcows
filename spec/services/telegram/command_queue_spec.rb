require 'rails_helper'

describe Telegram::CommandQueue, type: :service do
  let!(:channel) { Random.rand(@MAX_INT_VALUE) }

  before do
    allow(TelegramMessenger).to receive(:ask_level)
  end

  context 'given empty queue' do
    after do
      Telegram::CommandQueue.clear
    end

    it 'verify queue size' do
      expect(Telegram::CommandQueue.size).to eq(0)
    end

    it 'verify queue empty state' do
      expect(Telegram::CommandQueue.empty?).to be true
    end

    it 'verify clear succeeds' do
      expect(Telegram::CommandQueue.clear).to eq([])
    end

    it 'verify not present state' do
      expect(Telegram::CommandQueue.present?).to eq false
    end

    it 'verify not present state' do
      expect(Telegram::CommandQueue.present?).to eq false
    end

    it 'verify push increments queue size' do
      expect{
        Telegram::CommandQueue.push{ TelegramMessenger.ask_level(channel) }
      }.to change(Telegram::CommandQueue, :size).by(1)
    end
  end

  context 'given one command with assertion in a queue' do
    before do
      allow(GameEngineService).to receive(:settings)
      allow(GameEngineService).to receive(:language).and_return('RU')
      allow(TelegramMessenger).to receive(:level)

      Telegram::CommandQueue.push{ TelegramMessenger.ask_level(channel) }.to_confirm { |cls| cls == Telegram::Command::Level }
    end

    after do
      Telegram::CommandQueue.clear
    end

    it 'verify queue size' do
      expect(Telegram::CommandQueue.size).to eq(1)
    end

    it 'verify queue not empty state' do
      expect(Telegram::CommandQueue.empty?).to be false
    end

    it 'verify queue present state' do
      expect(Telegram::CommandQueue.present?).to be true
    end

    context 'with already executed command' do
      before do
        Telegram::CommandQueue.execute
      end

      it 'verify queue false assertion state' do
        expect(Telegram::CommandQueue.asserted?).to be false
      end

      xit 'verify queue /language command execution confirms assertion' do
        expect{
          Telegram::Command::Language.execute(channel, 'RU')
        }.not_to change(Telegram::CommandQueue, :asserted?)
      end

      it 'verify queue /level command execution confirms assertion' do
        expect{
          Telegram::Command::Level.execute(channel, 'easy')
        }.to change(Telegram::CommandQueue, :asserted?).to(true)
      end
    end
  end

end
