require 'rails_helper'

describe GamesController, :type => :request do

  it 'creates game with the secret word' do
    expect {
      post '/games', secret: 'hostel'
    }.to change(Game, :count).by(1) and expect_ok

    expect(json).to be
    expect(json['game']).to be
    expect(json['game']['source']).to eq('web')
    expect(json['game']['status']).to eq('created')
    expect(json['game']['secret']).to eq('******')

    expect(json['game']['tries']).to eq(0)
    expect(json['game']['hints']).to eq(0)

    expect(json['game']['link']).to match('/games/\d+')
  end

  context 'given dictionary in language with complexity levels' do
    let!(:easy) { create :dictionary_level, :easy_ru }
    let!(:dictionary) { create :dictionary, :russian, levels: [easy] }

    it 'creates game with randomly selected secret word where length, language, complexity specified' do
      data = {
          length: 5,
          language: 'RU',
          complexity: 'easy'
      }

      expect {
        post '/games', data
      }.to change(Game, :count).by(1) and expect_ok

      expect(json).to be
      expect(json['game']).to be
      expect(json['game']['status']).to eq('created')
      expect(json['game']['secret']).to eq('*****')
      expect(json['game']['language']).to eq('RU')
    end

    it 'fails to create game with with only language specified' do
      expect {
        post '/games', language: 'RU'
      }.not_to change(Game, :count) and expect_error
    end
  end

  context 'with multiple games' do
    let!(:en) { create :dictionary, lang: 'EN'}
    let!(:ru) { create :dictionary, lang: 'RU'}
    let!(:created_web_en)  { create :game, :created, :with_tries, secret: 'hostel', source: 'web', dictionary: en }
    let!(:running_web_ru)  { create :game, :running, :with_tries, secret: 'почта', source: 'web', dictionary: ru }
    let!(:finished_tel_en) { create :game, :finished, :with_tries, secret: 'magic', source: :telegram, dictionary: en }
    let!(:aborted_tel_ru)  { create :game, :aborted, :with_tries, secret: 'оборона', source: :telegram, dictionary: ru }

    it 'gets games collection' do
      expect {
        get '/games'
      }.not_to change(Game, :count) and expect_ok

      expect(json).to be
      expect(json['games']).to be
      expect(json['games'].count).to eq(4)
    end

    it 'gets only finished games' do
      expect {
        get '/games?status=finished'
      }.not_to change(Game, :count) and expect_ok

      expect(json).to be
      expect(json['games']).to be
      expect(json['games'].count).to eq(1)
    end

    it 'gets only telegram games' do
      expect {
        get '/games?source=telegram'
      }.not_to change(Game, :count) and expect_ok

      expect(json).to be
      expect(json['games']).to be
      expect(json['games'].count).to eq(2)
    end

    it 'gets no games with non existing status' do
      expect {
        get '/games?status=missing&source=web'
      }.not_to change(Game, :count) and expect_ok

      expect(json).to be
      expect(json['error']).not_to be

      expect(json['games']).to be
      expect(json['games']).to be_empty
    end

    it 'gets no games with non existing source' do
      expect {
        get '/games?status=created&source=mail'
      }.not_to change(Game, :count) and expect_ok

      expect(json).to be
      expect(json['error']).not_to be

      expect(json['games']).to be
      expect(json['games']).to be_empty
    end

    it 'gets paginated games collection' do
      expect {
        get '/games?per_page=2'
      }.not_to change(Game, :count) and expect_ok

      expect(json).to be
      expect(json['games']).to be
      expect(json['games'].count).to eq(2)
    end

    it 'gets games and ignores unknown filter parameters' do
      expect {
        get '/games?unknown=value'
      }.not_to change(Game, :count) and expect_ok

      expect(json).to be
      expect(json['games']).to be
      expect(json['games'].count).to eq(4)
    end
  end

  context 'with game in progress with few guesses placed' do
    let!(:dictionary) { create :dictionary, lang: 'EN'}
    let!(:game) { create :game, :running, :with_tries, :with_hints, secret: 'hostel', source: 'web', dictionary: dictionary }

    it 'gets game details' do
      expect {
        get "/games/#{game.id}"
      }.not_to change(Game, :count) and expect_ok

      expect(json).to be
      expect(json['game']).to be

      expect(json['game']['source']).to eq('web')
      expect(json['game']['status']).to eq('running')
      expect(json['game']['secret']).to eq('******')
      expect(json['game']['language']).to eq('EN')
      expect(json['game']['tries']).to eq(10)
      expect(json['game']['hints']).to eq(3)

      expect(json['game']['link']).to match('/games/\d+')
    end

    let!(:non_existent_game_id) { 832473246 }
    it 'replies with http status 404 on get for non existent game' do
      expect {
        get "/games/#{non_existent_game_id}"
      }.not_to change(Game, :count) and expect_not_found

      expect(json).to be
      expect(json['error']).to be

      expect(json['game']).not_to be
    end

    it 'stops the game' do
      expect {
        put "/games/#{game.id}", status: 'aborted'
      }.not_to change(Game, :count) and expect_ok

      expect(json).to be
      expect(json['game']).to be

      expect(json['game']['status']).to eq('aborted')
      expect(json['game']['link']).to match('/games/\d+')
    end

    it 'fails to create new game and gets 500 error' do
      expect {
        post '/games', secret: 'magic'
      }.not_to change(Game, :count) and expect_error

      expect(json).to be
      expect(json['error']).to be

      expect(json['game_link']).to eq("/games/#{game.id}")
    end

  end
end
