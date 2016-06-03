require 'rails_helper'

describe 'Bulls and Cows API' do
  context "with a secret word 'hostel'" do
    let!(:game) { create(:game, secret: 'hostel')}

    it 'places a guess with partially matched word' do
      data = {
          guess: 'postal'
      }
      expect {
        post "/games/#{game.id}/guesses", data
      }.to change(Guess, :count).by(1)

      expect(response).to be_success
      expect(json['bulls']).to eq(4) # O,S,T,L
      expect(json['cows']).to eq(0)
      expect(json['attempts']).to eq(1)
    end

    it 'places a guess with fully matched word' do
      data = {
          guess: 'hostel'
      }
      expect {
        post "/games/#{game.id}/guesses", data
      }.to change(Guess, :count).by(1)

      expect(response).to be_success
      expect(json['bulls']).to eq(6)
      expect(json['cows']).to eq(0)
      expect(json['attempts']).to eq(1)
    end

    context 'with another guess already submitted' do
      let!(:guess) { create(:guess, game_id: game.id, word: 'mortal')}

      it 'places a guess with partially matched word without increasing amount of attempts' do
        data = {
            guess: 'bandit'
        }
        expect {
          post "/games/#{game.id}/guesses", data
        }.to change(Guess, :count).by(1)

        expect(response).to be_success
        expect(json['attempts']).to eq(1)
      end
    end

    context 'with another guess for the same word already submitted' do
      let!(:guess) { create(:guess, game_id: game.id, word: 'mortal')}

      it 'places a guess with partially matched word increasing amount of attempts' do
        data = {
            guess: 'mortal'
        }
        expect {
          post "/games/#{game.id}/guesses", data
        }.not_to change(Guess, :count)

        expect(response).to be_success
        expect(json['attempts']).to eq(2)
      end
    end
  end
end