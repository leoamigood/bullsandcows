class GuessService

  def GuessService.guess(game, word)
    raise if game.secret.length != word.length

    guess = Guess.where(game_id: game.id, word: word).first
    if (guess.nil?)
      match = GuessService.match(word, game.secret)
      guess = Guess.create(match.merge(game_id: game.id, attempts: 1))

      game.guesses << guess
      game.save!
    else
      guess.attempts += 1
      guess.save!
    end

    guess
  end

  def GuessService.match(guess, secret)
    bulls = bulls(guess.split(''), secret.split(''))
    cows = cows(guess.split(''), secret.split(''))

    return {word: guess, bulls: bulls.compact.count, cows: cows.compact.count}
  end


  def GuessService.bulls(guess, secret)
    guess.zip(secret).map { |(g, s)| g == s ? g : nil}
  end

  def GuessService.cows(guess, secret)
    bulls = bulls(guess, secret)
    guess, secret = guess.zip(secret, bulls).
        map{|g, s, b| b.present? ? [nil, nil] : [g, s]}.transpose

    guess.each_with_index.map { |g, index|
      (i = secret.index(g)) && secret[i] = nil
      i.present? ? g : nil
    }
  end
end