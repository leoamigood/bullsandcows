require 'rails_helper'

describe HintsController, :type => :request  do
  context 'with a game started' do
    let!(:dictionary) { create :dictionary, lang: 'EN'}
    let!(:game) { create :game, :running, :with_tries, secret: 'hostel', source: 'web', dictionary: dictionary }

    it 'asks for any letter hint' do
      expect {
        post "/games/#{game.id}/hints"
        game.reload
      }.to change(game, :hints).by(1)

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['hint']).to be
      expect(json['hint']['match']).to eq(true)
      expect(json['hint']['letter']).to satisfy {
          |letter| game.secret.include?(letter)
      }

      expect(json['game_link']).to match("/games/#{game.id}")
    end

    it 'for a specified existent letter hint' do
      expect {
        post "/games/#{game.id}/hints", hint: 't'
        game.reload
      }.to change(game, :hints).by(1)

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['hint']).to be
      expect(json['hint']['match']).to eq(true)
      expect(json['hint']['letter']).to eq('t')

      expect(json['game_link']).to match("/games/#{game.id}")
    end

    it 'for a specified non existent letter hint' do
      expect {
        post "/games/#{game.id}/hints", hint: 'z'
        game.reload
      }.to change(game, :hints).by(1)

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['hint']).to be
      expect(json['hint']['match']).to eq(false)
      expect(json['hint']['letter']).to eq('z')

      expect(json['game_link']).to match("/games/#{game.id}")
    end
  end
end
