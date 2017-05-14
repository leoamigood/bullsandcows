require 'rails_helper'

describe ScoreService, type: :service do
  let!(:user)  { create :user, :telegram, :john_smith }
  let!(:other) { create :user, :telegram, :chris_pooh }
  let!(:third) { create :user, :telegram, :josef_gold }

  let!(:realm) { build :telegram_realm, user: user }

  it 'verify score worth for words with different lengths' do
    expect(ScoreService.worth('map', 'easy')).to eq(109)
    expect(ScoreService.worth('cart', 'easy')).to eq(138)
    expect(ScoreService.worth('magic', 'easy')).to eq(160)
    expect(ScoreService.worth('hostel', 'easy')).to eq(179)
    expect(ScoreService.worth('teacher', 'easy')).to eq(194)
    expect(ScoreService.worth('marathon', 'easy')).to eq(207)
    expect(ScoreService.worth('invention', 'easy')).to eq(219)
    expect(ScoreService.worth('cappuccino', 'easy')).to eq(230)
  end

  it 'verify score worth for words with different complexities' do
    expect(ScoreService.worth('hostel', 'easy')).to eq(179)
    expect(ScoreService.worth('hostel', 'medium')).to eq(193)
    expect(ScoreService.worth('hostel', 'hard')).to eq(205)
  end

  context 'when game with multiple guesses by one user only with one hint' do
    let!(:score) { create :score, worth: 179 }
    let!(:game) { create :game, secret: 'hostel', score: score, winner_id: realm.user.ext_id, status: :finished }

    let!(:hint) { create :hint, hint: 'h', game: game }

    let!(:guess1) { create :guess, word: 'castle', game: game, user_id: user.ext_id }
    let!(:guess2) { create :guess, word: 'poster', game: game, user_id: user.ext_id }
    let!(:guess3) { create :guess, word: 'master', game: game, user_id: user.ext_id }
    let!(:guess4) { create :guess, word: 'harbor', game: game, user_id: user.ext_id }
    let!(:guess5) { create :guess, word: 'hostel', game: game, user_id: user.ext_id }

    it 'calculate bonus points' do
      expect(ScoreService.bonus(game)).to eq(0)
    end

    it 'calculate cheat charge' do
      expect(ScoreService.penalty(game)).to eq(60)
    end
  end

  context 'when game with multiple users guesses and majority words are common' do
    let!(:score) { create(:score, worth: 179) }
    let!(:game) { create(:game, secret: 'hostel', score: score, winner_id: realm.user.ext_id, status: :finished) }

    let!(:guess_u1) { create :guess, word: 'castle', common: true, game: game, user_id: user.ext_id }
    let!(:guess_o1) { create :guess, word: 'poster', common: true, game: game, user_id: other.ext_id }
    let!(:guess_o2) { create :guess, word: 'master', common: true, game: game, user_id: other.ext_id }
    let!(:guess_o3) { create :guess, word: 'harbor', common: true, game: game, user_id: other.ext_id }
    let!(:guess_o4) { create :guess, word: 'portal', common: true, game: game, user_id: other.ext_id }
    let!(:guess_u2) { create :guess, word: 'zamper', common: false, game: game, user_id: user.ext_id }
    let!(:guess_u3) { create :guess, word: 'camper', common: true, game: game, user_id: user.ext_id }
    let!(:guess_o5) { create :guess, word: 'garage', common: true, game: game, user_id: other.ext_id }
    let!(:guess_u4) { create :guess, word: 'hostel', common: true, game: game, user_id: user.ext_id }

    it 'calculate bonus points' do
      expect(ScoreService.bonus(game)).to eq(20)
    end
  end

  context 'when game with multiple users guesses' do
    let!(:score) { create(:score, worth: 179) }
    let!(:game) { create(:game, secret: 'hostel', score: score, winner_id: realm.user.ext_id, status: :finished) }

    let!(:guess1) { create :guess, word: 'castle', game: game, user_id: user.ext_id }
    let!(:guess2) { create :guess, word: 'poster', game: game, user_id: other.ext_id }
    let!(:guess3) { create :guess, word: 'master', game: game, user_id: other.ext_id }
    let!(:guess4) { create :guess, word: 'harbor', game: game, user_id: other.ext_id }
    let!(:guess5) { create :guess, word: 'huddle', game: game, user_id: third.ext_id }
    let!(:guess6) { create :guess, word: 'portal', game: game, user_id: other.ext_id }
    let!(:guess7) { create :guess, word: 'hostel', game: game, user_id: user.ext_id }

    it 'calculate bonus points' do
      expect(ScoreService.bonus(game)).to eq(13)
    end

    it 'calculate penalty points' do
      expect(ScoreService.penalty(game)).to eq(0)
    end

    it 'calculate score points' do
      expect(ScoreService.points(game)).to eq(179 + 13)
    end

    context 'with one hint' do
      let!(:hint) { create(:hint, hint: 'h', game: game) }

      it 'calculate bonus points' do
        expect(ScoreService.bonus(game)).to eq(13)
      end

      it 'calculate penalty points' do
        expect(ScoreService.penalty(game)).to eq(60)
      end

      it 'calculate score points' do
        expect(ScoreService.points(game)).to eq(179 + 13 - 60)
      end
    end

    context 'with hints more than a half of the word letters' do
      let!(:hint1) { create(:hint, hint: 'h', game: game) }
      let!(:hint2) { create(:hint, hint: 'o', game: game) }
      let!(:hint3) { create(:hint, hint: 's', game: game) }
      let!(:hint4) { create(:hint, hint: 't', game: game) }

      it 'calculate bonus points' do
        expect(ScoreService.bonus(game)).to eq(13)
      end

      it 'calculate penalty points' do
        expect(ScoreService.penalty(game)).to eq(179 + 13)
      end

      it 'calculate score points' do
        expect(ScoreService.points(game)).to eq(179 + 13 - 179 - 13)
      end
    end
  end

  context 'when multiple scores in same channel by the user' do
    let!(:game1) { create :game, :realm, realm: realm, winner_id: user.ext_id, created_at: 5.days.ago }
    let!(:score1) { create :score, :winner_by_realm, realm: realm, game: game1, worth: 179, points: 162, created_at: 5.days.ago }

    let!(:game2) { create :game, :realm, realm: realm, winner_id: user.ext_id, created_at: 3.days.ago }
    let!(:score2) { create :score, :winner_by_realm, realm: realm, game: game2, worth: 229, points: 249, created_at: 3.days.ago }

    let!(:game3) { create :game, :realm, realm: realm, winner_id: user.ext_id, created_at: 1.hour.ago }
    let!(:score3) { create :score, :winner_by_realm, realm: realm, game: game3, worth: 340, points: 381, created_at: 1.hour.ago }

    it 'calculates total points for a latest game' do
      expect(ScoreService.total(game1)).to eq(162)
      expect(ScoreService.total(game2)).to eq(162 + 249)
      expect(ScoreService.total(game3)).to eq(162 + 249 + 381)
    end
  end

end
