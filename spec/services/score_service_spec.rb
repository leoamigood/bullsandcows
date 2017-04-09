require 'rails_helper'

describe ScoreService, type: :service do
  let!(:channel) { Random.rand(@MAX_INT_VALUE) }
  let!(:user) { User.new(Random.rand(@MAX_INT_VALUE), '@Amig0') }
  let!(:other) { User.new(Random.rand(@MAX_INT_VALUE), '@Other') }

  let!(:realm) { build :realm, :web, channel: channel, user_id: user.id }

  it 'verify score for the secret word' do
    expect{
      expect(ScoreService.build(Noun.new(noun: 'hostel'))).to have_attributes(worth: 179)
    }.not_to change(Score, :count)
  end

  it 'verify score for the secret word with different lengths' do
    expect(ScoreService.build(Noun.new(noun: 'map'))).to have_attributes(worth: 109)
    expect(ScoreService.build(Noun.new(noun: 'cart'))).to have_attributes(worth: 138)
    expect(ScoreService.build(Noun.new(noun: 'magic'))).to have_attributes(worth: 160)
    expect(ScoreService.build(Noun.new(noun: 'hostel'))).to have_attributes(worth: 179)
    expect(ScoreService.build(Noun.new(noun: 'teacher'))).to have_attributes(worth: 194)
    expect(ScoreService.build(Noun.new(noun: 'marathon'))).to have_attributes(worth: 207)
    expect(ScoreService.build(Noun.new(noun: 'invention'))).to have_attributes(worth: 219)
    expect(ScoreService.build(Noun.new(noun: 'cappuccino'))).to have_attributes(worth: 230)
  end

  it 'verify score for the secret word with different complexities' do
    expect(ScoreService.build(Noun.new(noun: 'hostel'), 'easy')).to have_attributes(worth: 179)
    expect(ScoreService.build(Noun.new(noun: 'hostel'), 'medium')).to have_attributes(worth: 193)
    expect(ScoreService.build(Noun.new(noun: 'hostel'), 'hard')).to have_attributes(worth: 205)
  end

  context 'when game with multiple guesses by one user only and one hint' do
    let!(:score) { create(:score, worth: 179) }
    let!(:game) { create(:game, :realm, secret: 'hostel', score: score, realm: realm, status: :finished) }

    let!(:hint) { create(:hint, hint: 'h', game: game) }

    let!(:guess1) { create(:guess, word: 'castle', game: game, user_id: user.id) }
    let!(:guess2) { create(:guess, word: 'poster', game: game, user_id: user.id) }
    let!(:guess3) { create(:guess, word: 'master', game: game, user_id: user.id) }
    let!(:guess4) { create(:guess, word: 'harbor', game: game, user_id: user.id) }
    let!(:guess5) { create(:guess, word: 'hostel', game: game, user_id: user.id) }

    it 'calculate bonus points' do
      expect(ScoreService.bonus(game)).to eq(0)
    end

    it 'calculate cheat charge' do
      expect(ScoreService.penalty(game)).to eq(30)
    end
  end

  context 'when game with multiple users guesses and one hint' do
    let!(:score) { create(:score, worth: 179) }
    let!(:game) { create(:game, :realm, secret: 'hostel', score: score, realm: realm, status: :finished) }

    let!(:hint) { create(:hint, hint: 'h', game: game) }

    let!(:guess1) { create(:guess, word: 'castle', game: game, user_id: user.id) }
    let!(:guess2) { create(:guess, word: 'poster', game: game, user_id: other.id) }
    let!(:guess3) { create(:guess, word: 'master', game: game, user_id: other.id) }
    let!(:guess4) { create(:guess, word: 'harbor', game: game, user_id: other.id) }
    let!(:guess5) { create(:guess, word: 'huddle', game: game, user_id: another = Random.rand(@MAX_INT_VALUE)) }
    let!(:guess6) { create(:guess, word: 'portal', game: game, user_id: other.id) }
    let!(:guess7) { create(:guess, word: 'hostel', game: game, user_id: user.id) }

    it 'calculate bonus points' do
      expect(ScoreService.bonus(game)).to eq(13)
    end

    it 'calculate cheat charge' do
      expect(ScoreService.penalty(game)).to eq(30)
    end
  end

end
