require 'rails_helper'

describe GameEngineService, type: :service do
  let!(:channel) { 169778030 }

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
      game = GameEngineService.create('channel-id-1', :telegram, Setting.complexities[:easy])

      expect(game).to be
      expect(game.level).to be_between(1, 2)
    end

    it 'create a game with specified amount of letters in secret word using secret word in specified level range' do
      game = GameEngineService.create_by_number('channel-id-1', 6, :telegram, Setting.complexities[:medium])

      expect(game).to be
      expect(game.secret.length).to eq(6)
      expect(game.level).to be_between(3, 4)
    end
  end

  it 'resolve game level numeric value by complexity string' do
    expect(GameEngineService.level('easy')).to eq([1, 2])
    expect(GameEngineService.level('medium')).to eq([3, 4])
    expect(GameEngineService.level('hard')).to eq([5])
  end

  context 'given no previously saved settings for user' do
    it 'persist game complexity setting' do
      setting = GameEngineService.settings(channel, {complexity: 'easy'})
      expect(setting.complexity).to eq('easy')
    end
  end

  context 'given previously saved complexity setting for user' do
    let!(:setting) { create :setting, complexity: 'easy'}

    it 'persist game complexity setting' do
      setting = GameEngineService.settings(channel, {complexity: 'hard'})
      expect(setting.complexity).to eq('hard')
    end
  end

end
