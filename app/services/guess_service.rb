class GuessService

  class << self
    def match(guess, secret)
      bulls = bulls(guess.split(''), secret.split(''))
      cows = cows(guess.split(''), secret.split(''))

      return {word: guess, bulls: bulls.compact.count, cows: cows.compact.count, exact: guess == secret}
    end

    def bulls(guess, secret)
      guess.zip(secret).map { |(g, s)| g == s ? g : nil}
    end

    def cows(guess, secret)
      bulls = bulls(guess, secret)
      guess, secret = guess.zip(secret, bulls).
          map{|g, s, b| b.present? ? [nil, nil] : [g, s]}.transpose

      guess.each_with_index.map { |g, index|
        (i = secret.index(g)) && secret[i] = nil
        i.present? ? g : nil
      }
    end
  end

end