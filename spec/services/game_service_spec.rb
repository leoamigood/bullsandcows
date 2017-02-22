require 'rails_helper'

describe GameService, type: :service do
  let!(:channel) { Random.rand(@MAX_INT_VALUE) }
  let!(:user) { User.new(Random.rand(@MAX_INT_VALUE), '@Amig0') }

  let!(:realm) { build :realm, :web, channel: channel, user_id: user.id }

  context 'with game not started' do
    context 'with a secret word' do
      let!(:secret) { create(:noun, noun: 'secret')}

      it 'creates a game' do
        game = GameService.create(realm, secret)

        expect(game).not_to be(nil)
        expect(game.secret).to eq('secret')
        expect(game.status).to eq('created')
        expect(game.dictionary).to eq(nil)
      end
    end

    it 'checks that game is not in progress' do
      expect(GameService.in_progress?(channel)).to eq(false)
    end
  end

  context 'with a game started' do
    let!(:game) { create(:game, :realm, secret: 'hostel', realm: realm)}

    it 'fails to create new game in the same channel' do
      expect{
        GameService.create(realm, Noun.new(noun: 'difference'))
      }.to raise_error(Errors::GameCreateException)
    end

    it 'creates new game in different channel' do
      recreated = GameService.create(Realm::Web.new('another-channel'), Noun.new(noun: 'canal'))

      expect(recreated).not_to be(nil)
      expect(recreated.secret).to eq('canal')
      expect(recreated.status).to eq('created')
      expect(recreated.dictionary).to eq(nil)
    end

    it 'finds game by channel' do
      expect {
        found = GameService.find_by_channel!(channel)

        expect(found).to be
        expect(found).to eq(game)
      }.not_to raise_error
    end

    it 'throws exception finding non existent game by channel' do
      expect{
        GameService.find_by_channel!('unknown-channel')
      }.to raise_error(Errors::GameNotFoundException)
    end

    it 'finds game by game id' do
      expect {
        found = GameService.find_by_id!(game.id)

        expect(found).to be
        expect(found).to eq(game)
      }.not_to raise_error
    end

    let!(:unknown_game_id) { 323492 }
    it 'throws exception finding game by non existent game id' do
      expect {
        found = GameService.find_by_id!(unknown_game_id)

        expect(found).to be
        expect(found).to eq(game)
      }.to raise_error(Errors::GameNotFoundException)
    end

    it 'places non full match guess' do
      expect {
        guess = GameService.guess(game, user, 'hornet')

        expect(guess).to be
        expect(guess.attempts).to eq(1)
        expect(guess.bulls).to eq(3)
        expect(guess.cows).to eq(1)
        expect(guess.exact).to eq(false)
      }.to change(game.reload, :status).to('running')
    end

    it 'places guess same word twice' do
      expect(GameService.guess(game, user, 'hornet').attempts).to eq(1)
      expect(GameService.guess(game, user, 'hornet').attempts).to eq(2)
    end

    it 'places a full match guess' do
      expect {
        guess = GameService.guess(game, user, 'hostel')

        expect(guess).to be
        expect(guess.attempts).to eq(1)
        expect(guess.bulls).to eq(6)
        expect(guess.cows).to eq(0)
        expect(guess.exact).to eq(true)
      }.to change(game.reload, :status).to('finished')
    end

    it 'asks for a random letter as a hint' do
      expect {
        hint = GameService.hint(game)

        expect(game.secret).to include(hint)
        expect(game.hints.count).to eq(1)
      }.to change(Hint, :count).by 1
    end

    it 'submits matching letter as a hint' do
      expect {
        hint = GameService.hint(game, 'l')

        expect(hint).to eq('l')
        expect(game.hints.count).to eq(1)
        expect(game.secret).to include(hint)
      }.to change(Hint, :count).by 1
    end

    it 'submits not matching letter as a hint' do
      expect {
        hint = GameService.hint(game, 'a')

        expect(hint).to be_nil
        expect(game.hints.count).to eq(1)
      }.to change(Hint, :count).by 1
    end

    it 'aborts the game' do
      GameService.stop!(game)

      expect(game.status).to eq('aborted')
    end

    it 'checks that game is not in progress' do
      expect(GameService.in_progress?(channel)).to eq(true)
    end
  end

  context 'with a game finished' do
    let!(:game) { create(:game, :realm, status: :finished, realm: realm)}

    it 'checks that game is in progress' do
      expect(GameService.in_progress?(channel)).to eq(false)
    end
  end

  context 'with a secret word given' do
    it 'returns letters in places of bulls' do
      expect(GameService.bulls('мораль'.split(''), 'корова'.split(''))).to eq([nil, 'о', 'р', nil, nil, nil])
      expect(GameService.bulls('краска'.split(''), 'корова'.split(''))).to eq(['к', nil, nil, nil, nil, 'а'])
    end

    it 'returns letters in places of cows' do
      expect(GameService.cows('мораль'.split(''), 'корова'.split(''))).to eq([nil, nil, nil, 'а', nil, nil])
      expect(GameService.cows('краска'.split(''), 'корова'.split(''))).to eq([nil, 'р', nil, nil, nil, nil])
    end

    it 'counts bulls and cows in input against the secret word' do
      expect(GameService.match('корень', 'корова')).to eq({word: 'корень', bulls: 3, cows: 0, exact: false})
      expect(GameService.match('восток', 'корова')).to eq({word: 'восток', bulls: 1, cows: 3, exact: false})
      expect(GameService.match('оборот', 'корова')).to eq({word: 'оборот', bulls: 0, cows: 3, exact: false})
      expect(GameService.match('краска', 'корова')).to eq({word: 'краска', bulls: 2, cows: 1, exact: false})
      expect(GameService.match('оборот', 'корова')).to eq({word: 'оборот', bulls: 0, cows: 3, exact: false})
      expect(GameService.match('корова', 'корова')).to eq({word: 'корова', bulls: 6, cows: 0, exact: true})

      expect(GameService.match('похоть', 'хребет')).to eq({word: 'похоть', bulls: 0, cows: 2, exact: false})
      expect(GameService.match('хартия', 'хребет')).to eq({word: 'хартия', bulls: 1, cows: 2, exact: false})
      expect(GameService.match('карате', 'хребет')).to eq({word: 'карате', bulls: 0, cows: 3, exact: false})
      expect(GameService.match('хребет', 'хребет')).to eq({word: 'хребет', bulls: 6, cows: 0, exact: true})

      expect(GameService.match('мораль', 'пароль')).to eq({word: 'мораль', bulls: 3, cows: 2, exact: false})
      expect(GameService.match('пассаж', 'пароль')).to eq({word: 'пассаж', bulls: 2, cows: 0, exact: false})
      expect(GameService.match('партер', 'пароль')).to eq({word: 'партер', bulls: 3, cows: 0, exact: false})
      expect(GameService.match('пароль', 'пароль')).to eq({word: 'пароль', bulls: 6, cows: 0, exact: true})
    end
  end

end
