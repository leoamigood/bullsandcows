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
      allow(TelegramMessenger).to receive(:level)

      Telegram::CommandQueue.push{ TelegramMessenger.ask_level(channel) }.callback { |cls| cls == Telegram::Command::Level }
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

    context 'when command had executed' do
      before do
        Telegram::CommandQueue.execute
      end

      it 'verify queue false assertion state' do
        expect(Telegram::CommandQueue.size).to eq(1)
      end

      let!(:dictionary) { create :dictionary, lang: 'RU'}
      it 'verify queue /language command fails expected callback assertion' do
        expect{
          Telegram::Command::Language.execute(channel, 'RU')
          expect(Telegram::CommandQueue.asserted?).to eq(false)
        }.not_to change(Telegram::CommandQueue, :size)
      end

      it 'verify queue /level command executes with successful callback and assertion' do
        expect{
          Telegram::Command::Level.execute(channel, 'easy')
          expect(Telegram::CommandQueue.asserted?).to eq(true)
        }.to change(Telegram::CommandQueue, :size).by(-1)
      end
    end
  end

end
