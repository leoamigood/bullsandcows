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

  context 'with multiple guesses for multiple games' do
    let!(:game1) { create :game, secret: 'cinema' }
    let!(:game2) { create :game, secret: 'portal' }

    let!(:guess1) { create :guess, id: 1, game: game1, word: 'staple', bulls: 1, cows: 1 }
    let!(:guess2) { create :guess, id: 2, game: game2, word: 'engine', bulls: 1, cows: 2 }
    let!(:guess3) { create :guess, id: 3, game: game2, word: 'eggnog', bulls: 1, cows: 2 }
    let!(:guess4) { create :guess, id: 4, game: game1, word: 'entire', bulls: 1, cows: 1 }

    it 'finds guesses for given games' do
      expect(game1.guesses).to match_array([guess1, guess4])
      expect(game2.guesses).to match_array([guess2, guess3])
    end

    it 'finds guesses for given games since (excluding) time' do
      expect(game1.guesses.since(nil)).to eq([guess1, guess4])
      expect(game1.guesses.since(guess1.created_at)).to eq([guess4])
      expect(game2.guesses.since(guess1.created_at)).to eq([guess2, guess3])
      expect(game2.guesses.since(guess4.created_at)).to be_empty
    end
  end

end
