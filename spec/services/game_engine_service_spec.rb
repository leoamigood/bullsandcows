require 'rails_helper'

describe GameEngineService, type: :service do
  let!(:channel) { Random.rand(@MAX_INT_VALUE) }
  let!(:user) { build :user, id: Random.rand(@MAX_INT_VALUE), name: '@Amig0' }

  let!(:realm) { build :realm, :telegram, channel: channel, user_id: user.id }

  it 'create a game with specified secret word' do
    game = GameEngineService.create_by_word(realm, 'magic')

    expect(game).to be
    expect(game.secret).to eq('magic')
    expect(game.level).not_to be
  end

  it 'sanitizes ambiguously spelled russian word' do
    game = GameEngineService.create_by_word(realm, 'посёлок')

    expect(game).to be
    expect(game.secret).to eq('поселок')
  end

  context 'given english dictionary with word levels and dictionary complexity levels breakdown' do
    let!(:medium) { create :dictionary_level, :medium_en }
    let!(:dictionary) { create :dictionary, :english, levels: [medium] }

    it 'fails to create a game with only word length' do
      expect {
        GameEngineService.create_by_options(realm, length: 6)
      }.to raise_error Errors::GameCreateException
    end

    context 'with length, complexity and language' do
      let!(:options) { { length: 6, complexity: 'medium', language: 'EN' } }

      it 'create a game with specified amount of letters, complexity and language' do
        game = GameEngineService.create_by_options(realm, options)

        expect(game).to be
        expect(game.secret.length).to eq(6)
        expect(game.level).to be_between(7, 9)
        expect(game.dictionary.EN?).to be(true)
      end

      context 'with recent games in the channel' do
        let!(:recent_game) { create(:game, channel: channel, secret: 'garlic', status: :finished, created_at: Time.now - 5.minutes) }

        it 'verify recent secrets are not reused' do
          game = GameEngineService.create_by_options(realm, options)

          expect(game).to be
          expect(game.secret).not_to eq(recent_game.secret)
        end
      end

      context 'with old and recent games in the channel' do
        let!(:old_game) { create(:game, channel: channel, secret: 'garlic', status: :finished, created_at: Time.now - 8.days) }
        let!(:recent_game) { create(:game, channel: channel, secret: 'parrot', status: :finished, created_at: Time.now - 2.days) }

        it 'verify recent secrets are not reused' do
          game = GameEngineService.create_by_options(realm, options)

          expect(game).to be
          expect(game.secret).not_to eq(recent_game.secret)
        end
      end

      context 'with old and recent games in multiple channels' do
        let!(:another) { Random.rand(@MAX_INT_VALUE) }

        let!(:old) { create(:game, channel: channel, secret: 'garlic', status: :finished, created_at: Time.now - 8.days) }
        let!(:another1) { create(:game, channel: another, secret: 'garlic', status: :finished, created_at: Time.now - 2.days) }
        let!(:recent) { create(:game, channel: channel, secret: 'parrot', status: :finished, created_at: Time.now - 3.days) }
        let!(:another2) { create(:game, channel: another, secret: 'parrot', status: :finished, created_at: Time.now - 5.days) }

        it 'verify recent secrets are not reused in same channel' do
          game = GameEngineService.create_by_options(realm, options)

          expect(game).to be
          expect(game.secret).not_to eq(recent.secret)
        end
      end
    end

    context 'with word length, complexity but without language' do
      let!(:options) { { length: 6, complexity: 'medium' } }

      it 'fails to create game without language' do
        expect{
          GameEngineService.create_by_options(realm, options)
        }.to raise_error Errors::GameCreateException
      end
    end
  end

  context 'given a game with a secret word' do
    let!(:game) { create(:game, :realm, secret: 'secret', realm: realm) }

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
      setting = GameEngineService.settings(realm.channel, {complexity: 'easy'})
      expect(setting.complexity).to eq('easy')
    end
  end

  context 'given previously saved complexity setting for user' do
    let!(:setting) { create :setting, complexity: 'easy'}

    it 'persist game complexity setting' do
      setting = GameEngineService.settings(realm.channel, {complexity: 'hard'})
      expect(setting.complexity).to eq('hard')
    end
  end

  context 'given a game with a russian secret word with ambiguous spelling' do
    let!(:game) { create(:game, :realm, secret: 'елка', realm: realm, status: :running) }

    it 'matches word with alternative spelling' do
      expect {
        expect(GameEngineService.guess(game, user, 'ёлка')).to have_attributes(word: 'елка')
      }.to change{ game.status }.to('finished')
    end

    it 'returns specified matching letter in a secret' do
      expect {
        expect(GameEngineService.hint(game, 'е')).to satisfy {
            |letter| game.secret.include?(letter)
        }
      }.to change{ game.hints.count }.by(1)
    end
  end

  context 'given scores for multiple games' do
    let!(:winner1) { 873784623 }
    let!(:winner2) { 223937424 }
    let!(:winner3) { 527567212 }

    let!(:game1) { create(:game, :realm, realm: realm, winner_id: winner1, created_at: 5.hours.ago) }
    let!(:score1) { create(:score, points: 179, game: game1) }

    let!(:game2) { create(:game, :realm, realm: realm, winner_id: winner2, created_at: 1.day.ago) }
    let!(:score2) { create(:score, points: 138, game: game2) }

    let!(:game3) { create(:game, :realm, realm: realm, winner_id: winner1, created_at: 2.days.ago) }
    let!(:score3) { create(:score, points: 205, game: game3) }

    let!(:game4) { create(:game, :realm, realm: realm, winner_id: winner3, created_at: 20.hours.ago) }
    let!(:score4) { create(:score, points: 152, game: game4) }

    let!(:game5) { create(:game, :realm, realm: realm, winner_id: winner2, created_at: 4.days.ago) }
    let!(:score5) { create(:score, points: 108, game: game5) }

    it 'calculate top scores for last week' do
      expect(GameEngineService.scores(channel).count).to eq(3)
      expect(GameEngineService.scores(channel)).to include([winner1, 179 + 205], [winner2, 138 + 108], [winner3, 152])
    end

    let(:last_3_days) { 3.days.ago..Time.now }
    it 'calculate top scores for last 3 days' do
      expect(GameEngineService.scores(channel, last_3_days).count).to eq(3)
      expect(GameEngineService.scores(channel, last_3_days)).to include([winner1, 179 + 205], [winner3, 152], [winner2, 138])
    end

    it 'calculate 2 top scores for last 3 days' do
      expect(GameEngineService.scores(channel, last_3_days, 2).count).to eq(2)
      expect(GameEngineService.scores(channel, last_3_days, 2)).to include([winner1, 179 + 205], [winner3, 152])
      expect(GameEngineService.scores(channel, last_3_days, 2)).not_to include(winner2)
    end
  end

end
