require 'rails_helper'

describe GameService, type: :service do
  let!(:user) { '@Amig0' }
  let!(:noun) { create(:noun, noun: 'secret')}

  it 'creates a game' do
    game = GameService.create('channel-id-1', Noun.new(noun: 'secret'), :web)

    expect(game).not_to be(nil)
    expect(game.secret).to eq('secret')
    expect(game.status).to eq('created')
    expect(game.dictionary).to eq(nil)
  end

  context 'with a game started' do
    let!(:game) { create(:game, secret: 'hostel')}

    it 'places non full match guess' do
      guess = GameService.guess(game, user, 'mortal')

      expect(guess).not_to be(nil)
      expect(game.status).to eq('running')
    end

    it 'places a full match guess' do
      guess = GameService.guess(game, user, 'hostel')

      expect(guess).not_to be(nil)
      expect(game.status).to eq('finished')
    end

  end

end