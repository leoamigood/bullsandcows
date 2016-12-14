require 'rails_helper'

describe HintsController, :type => :request  do
  context 'with a game started' do
    let!(:dictionary) { create :dictionary, lang: 'EN'}
    let!(:game) { create :game, :running, :with_tries, secret: 'hostel', source: 'web', dictionary: dictionary }

    it 'asks for any letter hint' do
      expect {
        post "/games/#{game.id}/hints"
      }.to change { game.hints.count }.by(1) and expect_ok

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
      }.to change{ game.hints.count }.by(1) and expect_ok

      expect(json).to be
      expect(json['hint']).to be
      expect(json['hint']['match']).to eq(true)
      expect(json['hint']['letter']).to eq('t')

      expect(json['game_link']).to match("/games/#{game.id}")
    end

    it 'for a specified non existent letter hint' do
      expect {
        post "/games/#{game.id}/hints", hint: 'z'
      }.to change{ game.hints.count }.by(1) and expect_ok

      expect(json).to be
      expect(json['hint']).to be
      expect(json['hint']['match']).to eq(false)
      expect(json['hint']['letter']).to eq('z')

      expect(json['game_link']).to match("/games/#{game.id}")
    end

    context 'with game having hints submitted' do
      let!(:hint1) { create :hint, game: game, letter: 'o', hint: 'o' }
      let!(:hint2) { create :hint, game: game, letter: 'a', hint: nil }
      let!(:hint3) { create :hint, game: game, letter: nil, hint: 's' }

      it 'lists all submitted hints' do
        expect {
          get "/games/#{game.id}/hints"
        }.not_to change(game, :status) and expect_ok

        expect(json).to be
        expect(json['hints']).to be
        expect(json['hints'].count).to eq(3)

        expect(json['hints'][0]).to include('letter' => 'o', 'match' => true)
        expect(json['hints'][1]).to include('letter' => 'a', 'match' => false)
        expect(json['hints'][2]).to include('letter' => 's', 'match' => true)

        expect(json['game_link']).to match("/games/#{game.id}")
      end
    end
  end
end
