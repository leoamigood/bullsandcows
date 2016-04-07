require 'rails_helper'

describe GuessService do

  context 'with a secret word given' do
    it 'returns true in places of bulls' do
      expect(GuessService.bulls('мораль'.split(''), 'корова'.split(''))).to eq([nil, 'о', 'р', nil, nil, nil])
      expect(GuessService.bulls('краска'.split(''), 'корова'.split(''))).to eq(['к', nil, nil, nil, nil, 'а'])
    end

    it 'returns true in places of cows' do
      expect(GuessService.cows('мораль'.split(''), 'корова'.split(''))).to eq([nil, nil, nil, 'а', nil, nil])
      expect(GuessService.cows('краска'.split(''), 'корова'.split(''))).to eq([nil, 'р', nil, nil, nil, nil])
    end

    it 'counts bulls and cows in input against the secret word' do
      expect(GuessService.match('корень', 'корова')).to eq([3, 0])
      expect(GuessService.match('восток', 'корова')).to eq([1, 3])
      expect(GuessService.match('оборот', 'корова')).to eq([0, 3])
      expect(GuessService.match('краска', 'корова')).to eq([2, 1])
      expect(GuessService.match('оборот', 'корова')).to eq([0, 3])
      expect(GuessService.match('корова', 'корова')).to eq([6, 0])

      expect(GuessService.match('похоть', 'хребет')).to eq([0, 2])
      expect(GuessService.match('хартия', 'хребет')).to eq([1, 2])
      expect(GuessService.match('карате', 'хребет')).to eq([0, 3])
      expect(GuessService.match('хребет', 'хребет')).to eq([6, 0])

      expect(GuessService.match('мораль', 'пароль')).to eq([3, 2])
      expect(GuessService.match('пассаж', 'пароль')).to eq([2, 0])
      expect(GuessService.match('партер', 'пароль')).to eq([3, 0])
      expect(GuessService.match('пароль', 'пароль')).to eq([6, 0])
    end

  end

end