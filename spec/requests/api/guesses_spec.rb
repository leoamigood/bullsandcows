require 'rails_helper'

describe 'Game API / Guess API' do
  context "with a secret word 'hostel'" do
    let!(:game) { create(:game, id: 1, secret: 'hostel')}
    let!(:guess) { create(:guess, game_id: game.id, word: 'mortal')}

    it 'submits a guess word' do
      data = {
          guess: 'postal'
      }
      expect {
        post "/games/#{game.id}/guesses", data
      }.to change(Guess, :count).by(1)

      expect(response).to be_success
    end
  end
end