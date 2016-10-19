require 'rails_helper'

describe GameEngineService, type: :service do
  let!(:channel) { 169778030 }

  it 'create a game with specified secret word' do
    game = GameEngineService.create_by_word(channel, 'magic', :telegram)

    expect(game).to be
    expect(game.secret).to eq('magic')
    expect(game.level).not_to be
  end

  context 'given russian dictionary with word levels' do
    let!(:dictionary) { create :dictionary, :words_with_levels, lang: 'RU'}

    context 'with complexity and language settings' do
      let!(:settings) { create :setting, channel: channel, complexity: 'medium', language: 'RU'}

      it 'create a game with specified amount of letters, complexity and language' do
        game = GameEngineService.create_by_number(channel, 6, :telegram)

        expect(game).to be
        expect(game.secret.length).to eq(6)
        expect(game.level).to be_between(3, 4)
        expect(game.dictionary.RU?).to be(true)
      end
    end

    context 'with missing language settings' do
      let!(:settings) { create :setting, channel: channel, language: 'EN'}

      it 'fails to create a game when no words exist in specified language ' do
        expect{
          GameEngineService.create_by_number(channel, 6, :telegram)
        }.to raise_error(/No words found in dictionaries/)
      end
    end
  end

  it 'resolve game level numeric value by complexity string' do
    expect(GameEngineService.get_level_by_complexity('easy')).to eq([1, 2])
    expect(GameEngineService.get_level_by_complexity('medium')).to eq([3, 4])
    expect(GameEngineService.get_level_by_complexity('hard')).to eq([5])
  end

  it 'get language or default language value' do
    expect(GameEngineService.get_language_or_default()).to eq('RU')
    expect(GameEngineService.get_language_or_default('EN')).to eq('EN')
    expect(GameEngineService.get_language_or_default('RU')).to eq('RU')
  end

  it 'raise error detecting unknown language' do
    expect{
      GameEngineService.get_language_or_default('IT')
    }.to raise_error('Language: IT is not available!')
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
