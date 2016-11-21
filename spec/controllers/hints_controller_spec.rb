require 'rails_helper'

describe HintsController, :type => :request  do
  context 'with a game started' do
    let!(:dictionary) { create :dictionary, lang: 'EN'}
    let!(:game) { create :game, :running, :with_tries, secret: 'hostel', source: 'web', dictionary: dictionary }

    it 'asks for any letter hint' do
      expect {
        post "/games/#{game.id}/hints"
      }.to change{ game.reload.hints }.by(1) and expect_ok

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
      }.to change{ game.reload.hints }.by(1) and expect_ok

      expect(json).to be
      expect(json['hint']).to be
      expect(json['hint']['match']).to eq(true)
      expect(json['hint']['letter']).to eq('t')

      expect(json['game_link']).to match("/games/#{game.id}")
    end

    it 'for a specified non existent letter hint' do
      expect {
        post "/games/#{game.id}/hints", hint: 'z'
      }.to change{ game.reload.hints }.by(1) and expect_ok

      expect(json).to be
      expect(json['hint']).to be
      expect(json['hint']['match']).to eq(false)
      expect(json['hint']['letter']).to eq('z')

      expect(json['game_link']).to match("/games/#{game.id}")
    end
  end
end
