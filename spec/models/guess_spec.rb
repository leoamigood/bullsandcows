require 'rails_helper'

describe Guess, type: :model do

  context 'with multiple guesses' do
    let!(:guess1) { create :guess, word: 'sector', bulls: 3, cows: 2 }
    let!(:guess2) { create :guess, word: 'master', bulls: 1, cows: 3 }
    let!(:guess3) { create :guess, word: 'staple', bulls: 1, cows: 2 }
    let!(:guess4) { create :guess, word: 'entire', bulls: 1, cows: 1 }

    it 'sort uses bulls over cows (1:3 ratio) for sorting' do
      expect([guess4, guess1, guess2, guess3].sort).to eq([guess1, guess2, guess3, guess4])
    end
  end

  context 'with multiple guesses with equal bulls and cows' do
    let!(:guess1) { create :guess, word: 'staple', bulls: 1, cows: 2 }
    let!(:guess2) { create :guess, word: 'engine', bulls: 1, cows: 2 }
    let!(:guess3) { create :guess, word: 'eggnog', bulls: 1, cows: 2 }

    it 'sort uses bulls over cows (1:3 ratio) for sorting' do
      expect([guess3, guess1, guess2].sort).to eq([guess1, guess2, guess3])
    end
  end
end