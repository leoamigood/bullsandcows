require 'rails_helper'

describe CommandQueue::Queue, type: :service do
  let!(:channel) { Random.rand(@MAX_INT_VALUE) }
  let!(:queue) { CommandQueue::Queue.new(channel) }

  before do
    allow(Telegram::TelegramMessenger).to receive(:ask_level)
  end

  after do
    queue.clear
  end
  
  context 'given empty queue' do
    it 'verify queue size' do
      expect(queue.size).to eq(0)
    end

    it 'verify successful assertion' do
      expect(queue.assert(self)).to be true
    end

    it 'verify queue empty state' do
      expect(queue.empty?).to be true
    end

    it 'verify queue present state' do
      expect(queue.present?).to be false
    end

    it 'verify clear succeeds' do
      expect(queue.clear).to eq([])
    end

    it 'verify reset succeeds' do
      expect(queue.reset).to eq(queue)
    end

    context 'given a command' do
      let!(:command) { CommandQueue::Exec.new('Telegram::TelegramMessenger.ask_level', channel) }

      it 'verify push command increments queue size' do
        expect{
          queue.push(command)
        }.to change(queue, :size).by(1)
      end
    end
  end

  context 'given one command with assertion in a queue' do
    let!(:command) { CommandQueue::Exec.new('Telegram::TelegramMessenger.ask_level', channel, Telegram::Action::Level.self?) }

    before do
      allow(GameEngineService).to receive(:settings)
      allow(Telegram::TelegramMessenger).to receive(:level)

      queue.push(command)
    end

    it 'verify queue size' do
      expect(queue.size).to eq(1)
    end

    it 'verify queue not empty state' do
      expect(queue.empty?).to be false
    end

    it 'verify queue present state' do
      expect(queue.present?).to be true
    end

    context 'when command gets executed' do
      before do
        expect(queue.execute).to be_nil
        expect(Telegram::TelegramMessenger).to have_received(:ask_level).with(channel)
      end

      it 'verify command remains in a queue' do
        expect{
          expect(queue.empty?).to be false
        }.not_to change(queue, :size)
      end

      it 'verify command /language not executed and stays in the queue' do
        expect{
          Telegram::Action::Language.execute(channel, 'RU')
          expect(GameEngineService).not_to have_received(:settings)
        }.not_to change(queue, :size)
      end

      it 'verify command /level gets executed and removed from the queue' do
        expect{
          Telegram::Action::Level.execute(channel, 'easy')
          expect(GameEngineService).to have_received(:settings)
        }.to change(queue, :size).by(-1)
      end
    end
  end

end
