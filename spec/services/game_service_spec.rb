require 'rails_helper'

describe GameService do

  it 'creates a game' do
    game = GameService.create('secret')

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