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

    it 'verify successful assertion' do
      expect(Telegram::CommandQueue.assert(self)).to be true
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

      Telegram::CommandQueue.push(Proc.new{|cls| cls == Telegram::Command::Level }) { 'block' + ' to execute' }
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

    context 'when command gets executed' do
      before do
        expect(Telegram::CommandQueue.execute).to eq('block to execute')
      end

      it 'verify command to remain in a queue' do
        expect{
          expect(Telegram::CommandQueue.present?).to be true
        }.not_to change(Telegram::CommandQueue, :size)
      end

      it 'verify command /language fails expected callback assertion' do
        expect{
          Telegram::Command::Language.execute(channel, 'RU')
          expect(Telegram::CommandQueue.asserted?).to eq(false)
          expect(GameEngineService).not_to have_received(:settings)
        }.not_to change(Telegram::CommandQueue, :size)
      end

      it 'verify command /level executes with successful callback and assertion' do
        expect{
          Telegram::Command::Level.execute(channel, 'easy')
          expect(Telegram::CommandQueue.asserted?).to eq(true)
          expect(GameEngineService).to have_received(:settings)
        }.to change(Telegram::CommandQueue, :size).by(-1)
      end
    end
  end

end
