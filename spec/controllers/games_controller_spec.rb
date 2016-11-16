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

  context 'with multiple games' do
    let!(:en) { create :dictionary, lang: 'EN'}
    let!(:ru) { create :dictionary, lang: 'RU'}
    let!(:created_web_en)  { create :game, :created, :with_tries, secret: 'hostel', source: 'web', dictionary: en }
    let!(:running_web_ru)  { create :game, :running, :with_tries, secret: 'почта', source: 'web', dictionary: ru }
    let!(:finished_tel_en) { create :game, :finished, :with_tries, secret: 'magic', source: :telegram, dictionary: en }
    let!(:aborted_tel_ru)  { create :game, :aborted, :with_tries, secret: 'оборона', source: :telegram, dictionary: ru }

    it 'gets games collection' do
      get '/games'

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['games']).to be
      expect(json['games'].count).to eq(4)
    end

    it 'gets only finished games' do
      get '/games?status=finished'

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['games']).to be
      expect(json['games'].count).to eq(1)
    end

    it 'gets only telegram games' do
      get '/games?source=telegram'

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['games']).to be
      expect(json['games'].count).to eq(2)
    end

    it 'gets no games with non existing status' do
      get '/games?status=missing&source=web'

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['error']).not_to be

      expect(json['games']).to be
      expect(json['games']).to be_empty
    end

    it 'gets no games with non existing source' do
      get '/games?status=created&source=mail'

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['error']).not_to be

      expect(json['games']).to be
      expect(json['games']).to be_empty
    end


    it 'gets games and ignores unknown filter parameters' do
      get '/games?unknown=value'

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['games']).to be
      expect(json['games'].count).to eq(4)
    end
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
