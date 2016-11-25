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
    let!(:medium) { create :dictionary_level, :medium }
    let!(:dictionary) { create :dictionary, :words_with_levels, levels: [medium], lang: 'RU' }

    context 'with complexity and language settings' do
      let!(:settings) { create :setting, channel: channel, dictionary: dictionary, complexity: 'medium', language: 'RU'}

      it 'create a game with specified amount of letters, complexity and language' do
        game = GameEngineService.create_by_number(channel, 6, :telegram)

        expect(game).to be
        expect(game.secret.length).to eq(6)
        expect(game.level).to be_between(7, 9)
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

  context 'given a game with a secret word' do
    let!(:game) { create(:game, :telegram, secret: 'secret', channel: channel) }

    it 'reveals one random letter in a secret' do
      expect {
        expect(GameEngineService.hint(game)).to satisfy {
            |letter| game.secret.include?(letter)
        }
      }.to change{ game.reload.hints }.by(1)
    end

    it 'returns specified matching letter in a secret' do
      expect {
        expect(GameEngineService.hint(game, 's')).to satisfy {
            |letter| game.secret.include?(letter)
        }
      }.to change{ game.reload.hints }.by(1)
    end

    it 'returns nil for specified NON matching letter in a secret' do
      expect {
        expect(GameEngineService.hint(game, 'x')).to be_nil
      }.to change{ game.reload.hints }.by(1)
    end
  end

  it 'get language or default language value' do
    expect(GameEngineService.get_language_or_default()).to eq('RU')
    expect(GameEngineService.get_language_or_default('EN')).to eq('EN')
    expect(GameEngineService.get_language_or_default('RU')).to eq('RU')
  end

  it 'raise error detecting unknown language' do
    expect{
      GameEngineService.get_language_or_default('DE')
    }.to raise_error('Language: DE is not available!')
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
