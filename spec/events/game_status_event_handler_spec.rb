require 'rails_helper'

describe GameStatusEventHandler, type: :event do
  let!(:user) { build :user, id: Random.rand(@MAX_INT_VALUE), name: '@Amig0' }

  context 'when game has finished' do
    let!(:game) { create :finished_game, winner: user.id }
    let!(:payload) { { game: game } }

    it 'game winner id is updated' do
      expect{
        GameStatusEventHandler.game_finished(payload)
      }.to change{ game.reload.winner_id }.to(user.id)
    end
  end

end
