require 'rails_helper'

describe GameEngineService, type: :service do

  context 'given basic dictionary' do
    let!(:dictionary) { create :dictionary, :basic, lang: 'RU'}

    it 'create a game' do
      game = GameEngineService.create('channel-id-1', :telegram)

      expect(game).to be
      expect(game.level).not_to be
    end

    it 'create a game with specified secret word' do
      game = GameEngineService.create_by_word('channel-id-1', 'magic', :telegram)

      expect(game).to be
      expect(game.secret).to eq('magic')
      expect(game.level).not_to be
    end

    it 'create a game with specified amount of letters in secret word' do
      game = GameEngineService.create_by_number('channel-id-1', 6, :telegram)

      expect(game).to be
      expect(game.secret.length).to eq(6)
      expect(game.level).not_to be
    end
  end

  context 'given dictionary with word levels' do
    let!(:dictionary) { create :dictionary, :words_with_levels, lang: 'RU'}

    it 'create a game using secret word in specified level range' do
      game = GameEngineService.create('channel-id-1', 1..6)

      expect(game).to be
      expect(game.level).to be_between(1, 6)
    end

    it 'create a game with specified amount of letters in secret word using secret word in specified level range' do
      game = GameEngineService.create_by_number('channel-id-1', 6, :telegram, 3..4)

      expect(game).to be
      expect(game.secret.length).to eq(6)
      expect(game.level).to be_between(3, 4)
    end
  end

end
