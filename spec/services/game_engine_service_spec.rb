require 'rails_helper'

describe GameEngineService, type: :service do
  let!(:channel) { Random.rand }

  it 'create a game with specified secret word' do
    game = GameEngineService.create_by_word(channel, :telegram, 'magic')

    expect(game).to be
    expect(game.secret).to eq('magic')
    expect(game.level).not_to be
  end

  context 'given english dictionary with word levels and dictionary complexity levels breakdown' do
    let!(:medium) { create :dictionary_level, :medium_en }
    let!(:dictionary) { create :dictionary, :english, levels: [medium] }

    it 'fails to create a game with only word length' do
      expect {
        GameEngineService.create_by_options(channel, :telegram, length: 6)
      }.to raise_error Errors::GameCreateException
    end

    context 'with length, complexity and language' do
      let!(:options) { { length: 5, complexity: 'medium', language: 'EN' } }

      it 'create a game with specified amount of letters, complexity and language' do
        game = GameEngineService.create_by_options(channel, :telegram, options)

        expect(game).to be
        expect(game.secret.length).to eq(5)
        expect(game.level).to be_between(7, 9)
        expect(game.dictionary.EN?).to be(true)
      end
    end

    context 'with word length, complexity but without language' do
      let!(:options) { { length: 6, complexity: 'medium' } }

      it 'fails to create game without language' do
        expect{
          GameEngineService.create_by_options(channel, :telegram, options)
        }.to raise_error Errors::GameCreateException
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
      }.to change{ game.hints.count }.by(1)
    end

    it 'returns specified matching letter in a secret' do
      expect {
        expect(GameEngineService.hint(game, 's')).to satisfy {
            |letter| game.secret.include?(letter)
        }
      }.to change{ game.hints.count }.by(1)
    end

    it 'returns nil for specified NON matching letter in a secret' do
      expect {
        expect(GameEngineService.hint(game, 'x')).to be_nil
      }.to change{ game.hints.count }.by(1)
    end
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
