require 'rails_helper'

describe CommandQueue::TurnpikeDelegate, type: :service do
  let!(:channel) { Random.rand(@MAX_INT_VALUE) }
  let!(:queue) { CommandQueue::TurnpikeDelegate.new(channel) }

  before do
    queue.clear
  end

  after do
    queue.clear
  end

  context 'given empty queue' do
    it 'verify queue size' do
      expect(queue.size).to eq(0)
    end

    it 'verify queue empty state' do
      expect(queue.empty?).to be true
    end

    it 'verify clear succeeds' do
      expect(queue.clear).to eq([])
    end

    it 'verify push element adds one element' do
      expect{
        queue.push('data')
      }.to change(queue, :size).by(1)
    end

    it 'verify push array adds one element' do
      expect{
        queue.push(%w(one two))
      }.to change(queue, :size).by(1)
    end

    it 'verify push multiple elements adds multiple elements' do
      expect{
        queue.push('one', 'two')
      }.to change(queue, :size).by(2)
    end
  end

  context 'given one one item in a queue' do
    let!(:command1) { CommandQueue::Exec.new('String.new', 'first item') }

    before do
      queue.push(command1)
    end

    it 'verify queue size' do
      expect(queue.size).to eq(1)
    end

    it 'verify queue not empty state' do
      expect(queue.empty?).to be false
    end

    it 'verify first item to be popped next' do
      expect(queue.peek).to eq(command1)
    end

    it 'verify popped item' do
      expect(queue.pop).to eq(command1)
    end

    it 'verify queue is empty after item was popped' do
      expect(queue.pop).to eq(command1)
      expect(queue.size).to eq(0)
      expect(queue.empty?).to be true
    end

    it 'verify there is only one item can be popped' do
      expect(queue.pop).to eq(command1)
      expect(queue.pop).to be_nil
    end

    it 'verify queue can hold multiple same items' do
      expect{
        queue.push(command1)
      }.to change(queue, :size).by(1)
    end

    let!(:command2) { CommandQueue::Exec.new('String.new', 'first item') }
    let!(:command3) { CommandQueue::Exec.new('String.new', 'first item') }
    it 'verify queue order with multiple push and pop' do
      expect{
        queue.push(command2)
        queue.push(command3)

        expect(queue.pop).to eq(command1)
        expect(queue.pop).to eq(command2)
        expect(queue.pop).to eq(command3)
      }.to change(queue, :size).by(-1)
    end
  end

end
