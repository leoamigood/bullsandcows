require 'rails_helper'

describe GameService, type: :service do
  let!(:noun) { create(:noun, noun: 'secret')}

  it 'creates a game' do
    game = GameService.create('channel-id-1', 'secret', :web)

    expect(game).not_to be(nil)
    expect(game.secret).to eq('secret')
    expect(game.status).to eq('created')
  end

  context 'with a game started' do
    let!(:game) { create(:game, secret: 'hostel')}

    it 'places non full match guess' do
      guess = GameService.guess(game, 'mortal')

      expect(guess).not_to be(nil)
      expect(game.status).to eq('running')
    end

    it 'places a full match guess' do
      guess = GameService.guess(game, 'hostel')

      expect(guess).not_to be(nil)
      expect(game.status).to eq('finished')
    end

  end

end