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

  context 'given russian dictionary with word levels' do
    let!(:dictionary) { create :dictionary, :words_with_levels, lang: 'RU'}

    it 'create a game using secret word in specified level range' do
      game = GameEngineService.create('channel-id-1', :telegram, {complexity: Setting.complexities[:easy]})

      expect(game).to be
      expect(game.level).to be_between(1, 2)
    end

    it 'create a game with specified amount of letters using language and complexity' do
      options = {complexity: Setting.complexities[:medium], language: 'russian'}
      game = GameEngineService.create_by_number('channel-id-1', 6, :telegram, options)

      expect(game).to be
      expect(game.secret.length).to eq(6)
      expect(game.level).to be_between(3, 4)
      expect(game.dictionary.russian?).to be(true)
    end

    it 'fails to create a game when no words exist in specified language ' do
      expect{
        GameEngineService.create('channel-id-1', :telegram, {language: 'english'})
      }.to raise_error(/No words found in dictionaries with options/)
    end
  end

  it 'resolve game level numeric value by complexity string' do
    expect(GameEngineService.get_level_by_complexity('easy')).to eq([1, 2])
    expect(GameEngineService.get_level_by_complexity('medium')).to eq([3, 4])
    expect(GameEngineService.get_level_by_complexity('hard')).to eq([5])
  end

  it 'get language or default language value' do
    expect(GameEngineService.get_language_or_default()).to eq('RU')
    expect(GameEngineService.get_language_or_default('english')).to eq('EN')
    expect(GameEngineService.get_language_or_default('russian')).to eq('RU')
  end

  it 'raise error detecting unknown language' do
    expect{
      GameEngineService.get_language_or_default('italian')
    }.to raise_error('Language: italian is not available. Please try another!')
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
