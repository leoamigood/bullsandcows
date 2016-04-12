class GameService

  def GameService.create(secret)
    Game.create({secret: secret})
  end

  def GameService.guess(game, word)
    raise if game.secret.length != word.length

    guess = Guess.where(game_id: game.id, word: word).take
    if (guess.nil?)
      match = GuessService.match(word, game.secret)
      guess = Guess.create(match.merge(game_id: game.id, attempts: 1))

      game.status = match[:exact].present? ? :finished : :running
      game.save!
    else
      guess.attempts += 1
      guess.save!
    end

    guess
  end
end