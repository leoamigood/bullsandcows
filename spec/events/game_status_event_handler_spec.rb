require 'rails_helper'

describe GameStatusEventHandler, type: :event do
  let!(:user) { build :user, id: Random.rand(@MAX_INT_VALUE), name: '@Amig0' }

  context 'when game has finished' do
    let!(:winning) { build(:guess, exact: true, word: 'hostel', bulls: 6, cows: 0, user_id: user.id) }
    let!(:game) { create :finished_game, exact_guess: winning }
    let!(:payload) { { game: game } }

    it 'game winner id is updated' do
      expect{
        GameStatusEventHandler.game_finished(payload)
      }.to change{ game.reload.winner_id }.to(user.id)
    end
  end

end
