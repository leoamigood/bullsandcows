require 'rails_helper'

describe GameStatusEventHandler, type: :event do
  let!(:user) { create :user, username: '@Amig0' }

  context 'when game has finished' do
    let!(:game) { create :finished_game, winner: user.ext_id }
    let!(:payload) { { game: game } }

    it 'game winner id is updated' do
      expect{
        GameStatusEventHandler.game_finished(payload)
      }.to change{ game.reload.winner_id }.to(user.ext_id)
    end
  end

end
