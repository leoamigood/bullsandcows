require 'rails_helper'

describe GuessesController  do
  context "with a secret word 'hostel'" do
    let!(:game) { create(:game, id: 1, secret: 'hostel')}

    it 'submits a guess word' do
      data = {
          guess: 'postal'
      }
      expect {
        post :create, data.merge(game_id: game.id)
      }.to change(Guess, :count).by(1)

      expect(response).to be_success
    end
  end
end