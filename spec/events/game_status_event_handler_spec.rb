require 'rails_helper'

describe GameStatusEventHandler, type: :event do
  let!(:user) { create :user, :telegram, :john_smith }

  context 'when game has finished' do
    let!(:winning) { build :guess, exact: true, word: 'hostel', bulls: 6, cows: 0, user_id: user.ext_id }
    let!(:game) { create :finished_game, exact_guess: winning }
    let!(:payload) { { game: game } }

    it 'game winner id is updated' do
      expect{
        GameStatusEventHandler.game_finished(payload)
      }.to change{ game.reload.winner_id }.to(user.ext_id)
    end
  end

end
