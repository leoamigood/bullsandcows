require 'rails_helper'

describe GuessesController, :type => :request  do
  context 'with a game started' do
    let!(:dictionary) { create :dictionary, lang: 'EN'}
    let!(:game) { create :game, :running, :with_tries, secret: 'hostel', source: 'web', dictionary: dictionary }

    it 'submits non exact guess word' do
      expect {
        post "/games/#{game.id}/guesses", guess: 'corpus'
      }.to change(Guess, :count).by(1)

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['guess']).to be
      expect(json['guess']['link']).to match("/games/#{game.id}/guesses/\\d+")
      expect(json['guess']['word']).to eq('corpus')
      expect(json['guess']['bulls']).to eq(1)
      expect(json['guess']['cows']).to eq(1)
      expect(json['guess']['attempts']).to eq(1)
      expect(json['guess']['exact']).to be(false)

      expect(json['game_link']).to match("/games/#{game.id}")
    end

    it 'submits exact guess word' do
      expect {
        post "/games/#{game.id}/guesses", guess: 'hostel'
      }.to change(Guess, :count).by(1)

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['guess']).to be
      expect(json['guess']['link']).to match("/games/#{game.id}/guesses/\\d+")
      expect(json['guess']['word']).to eq('hostel')
      expect(json['guess']['bulls']).to eq(6)
      expect(json['guess']['cows']).to eq(0)
      expect(json['guess']['attempts']).to eq(1)
      expect(json['guess']['exact']).to be(true)

      expect(json['game_link']).to match("/games/#{game.id}")
    end

    it 'gets all previously submitted guesses' do
      expect {
        get "/games/#{game.id}/guesses"
      }.not_to change(game, :status)

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['guesses']).to be
      expect(json['guesses'].count).to eq(game.guesses.count)

      expect(json['game_link']).to match("/games/#{game.id}")
    end

    it 'gets N best guesses submitted guesses' do
      expect {
        get "/games/#{game.id}/guesses?best=3"
      }.not_to change(game, :status)

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['best']).to be
      expect(json['best'].count).to eq(3)

      expect(json['game_link']).to match("/games/#{game.id}")
    end

    it 'gets more than available best submitted guesses' do
      expect {
        get "/games/#{game.id}/guesses?best=15"
      }.not_to change(game, :status)

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['best']).to be
      expect(json['best'].count).to eq(game.guesses.count)

      expect(json['game_link']).to match("/games/#{game.id}")
    end

    it 'gets ALL best submitted guesses' do
      expect {
        get "/games/#{game.id}/guesses?best="
      }.not_to change(game, :status)

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['best']).to be
      expect(json['best'].count).to eq(game.guesses.count)

      expect(json['game_link']).to match("/games/#{game.id}")
    end

    it 'gets N zero submitted guesses' do
      expect {
        get "/games/#{game.id}/guesses?zero=1"
      }.not_to change(game, :status)

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['zero']).to be
      expect(json['zero'].count).to eq(1)

      expect(json['game_link']).to match("/games/#{game.id}")
    end

    it 'gets more than available zero submitted guesses' do
      expect {
        get "/games/#{game.id}/guesses?zero=15"
      }.not_to change(game, :status)

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['zero']).to be
      expect(json['zero'].count).to eq(2)

      expect(json['game_link']).to match("/games/#{game.id}")
    end

    it 'gets ALL zero submitted guesses' do
      expect {
        get "/games/#{game.id}/guesses?zero="
      }.not_to change(game, :status)

      expect(response).to be_success
      expect(response).to have_http_status(200)

      expect(json).to be
      expect(json['zero']).to be
      expect(json['zero'].count).to eq(2)

      expect(json['game_link']).to match("/games/#{game.id}")
    end
  end

  let!(:non_existent_game_id) { 832473246 }
  it 'submits a guess word for non existent game' do
    expect {
      post "/games/#{non_existent_game_id}/guesses", guess: 'corpus'
    }.not_to change(Guess, :count)

    expect(response).not_to be_success
    expect(response).to have_http_status(500)

    expect(json).to be
    expect(json['error']).to be

    expect(json['guess']).not_to be
    expect(json['game_link']).not_to be
  end

  context 'with a game finished' do
    let!(:game) { create(:game, :finished, secret: 'hostel')}

    it 'submits a guess word' do
      expect {
        post "/games/#{game.id}/guesses", guess: 'corpus'
      }.not_to change(Guess, :count)

      expect(response).not_to be_success
      expect(response).to have_http_status(500)

      expect(json).to be
      expect(json['error']).to be

      expect(json['guess']).not_to be
      expect(json['game_link']).to match("/games/#{game.id}")
    end
  end
end
