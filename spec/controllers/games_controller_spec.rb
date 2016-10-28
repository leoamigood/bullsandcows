require 'rails_helper'

describe GamesController, :type => :request do
  it 'creates game with the secret word' do
    post '/games', secret: 'hostel'

    expect(response).to be_success
    expect(response).to have_http_status(200)

    expect(json).to be
    expect(json['game']).to be
    expect(json['game']['source']).to eq('web')
    expect(json['game']['status']).to eq('created')
    expect(json['game']['secret']).to eq('******')
    # expect(json['game']['language']).to eq('EN')
    expect(json['game']['tries']).to eq(0)
    expect(json['game']['hints']).to eq(0)

    expect(json['game']['link']).to match('/games/\d+')
  end

  context 'with game in progress with few guesses placed' do
    let!(:dictionary) { create :dictionary, lang: 'EN'}
    let!(:game) { create :game, :running, :with_tries, secret: 'hostel', source: 'web', dictionary: dictionary }

    it 'gets game details' do
      get "/games/#{game.id}"

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['game']).to be

      expect(json['game']['source']).to eq('web')
      expect(json['game']['status']).to eq('running')
      expect(json['game']['secret']).to eq('******')
      expect(json['game']['language']).to eq('EN')
      expect(json['game']['tries']).to eq(10)
      expect(json['game']['hints']).to eq(0)

      expect(json['game']['link']).to match('/games/\d+')
    end

    let!(:non_existent_game_id) { 832473246 }
    it 'fails to get non existent game' do
      get "/games/#{non_existent_game_id}"

      expect(response).not_to be_success
      expect(response).to have_http_status(500)

      expect(json).to be
      expect(json['error']).to be

      expect(json['game']).not_to be
    end

    it 'aborts the game' do
      put "/games/#{game.id}", status: 'aborted'

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['game']).to be

      expect(json['game']['status']).to eq('aborted')
      expect(json['game']['link']).to match('/games/\d+')
    end
  end
end
