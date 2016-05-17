require 'rails_helper'

describe GuessService, type: :service do

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
      expect(GuessService.match('корень', 'корова')).to eq({word: 'корень', bulls: 3, cows: 0, exact: false})
      expect(GuessService.match('восток', 'корова')).to eq({word: 'восток', bulls: 1, cows: 3, exact: false})
      expect(GuessService.match('оборот', 'корова')).to eq({word: 'оборот', bulls: 0, cows: 3, exact: false})
      expect(GuessService.match('краска', 'корова')).to eq({word: 'краска', bulls: 2, cows: 1, exact: false})
      expect(GuessService.match('оборот', 'корова')).to eq({word: 'оборот', bulls: 0, cows: 3, exact: false})
      expect(GuessService.match('корова', 'корова')).to eq({word: 'корова', bulls: 6, cows: 0, exact: true})

      expect(GuessService.match('похоть', 'хребет')).to eq({word: 'похоть', bulls: 0, cows: 2, exact: false})
      expect(GuessService.match('хартия', 'хребет')).to eq({word: 'хартия', bulls: 1, cows: 2, exact: false})
      expect(GuessService.match('карате', 'хребет')).to eq({word: 'карате', bulls: 0, cows: 3, exact: false})
      expect(GuessService.match('хребет', 'хребет')).to eq({word: 'хребет', bulls: 6, cows: 0, exact: true})

      expect(GuessService.match('мораль', 'пароль')).to eq({word: 'мораль', bulls: 3, cows: 2, exact: false})
      expect(GuessService.match('пассаж', 'пароль')).to eq({word: 'пассаж', bulls: 2, cows: 0, exact: false})
      expect(GuessService.match('партер', 'пароль')).to eq({word: 'партер', bulls: 3, cows: 0, exact: false})
      expect(GuessService.match('пароль', 'пароль')).to eq({word: 'пароль', bulls: 6, cows: 0, exact: true})
    end

  end

end