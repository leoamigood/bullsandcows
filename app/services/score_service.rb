class ScoreService

  class << self
    def build(secret, complexity = 'easy')
      Score.new(worth: worth(secret, complexity))
    end

    def points(game)
      [game.score.worth + bonus(game) - penalty(game), 0].max
    end

    def bonus(game)
      user_guesses, others = game.guesses.partition { |g| g.user_id == game.user_id }
      return 0 if others.empty?

      ratio = (others.count.to_f / others.group_by(&:user_id).count - user_guesses.count) / game.guesses.count
      ([ratio, 0].max * game.score.worth).round
    end

    def penalty(game)
      ratio = game.hints.count.to_f / game.secret.length
      (ratio * game.score.worth).round
    end

    def worth(secret, complexity)
      points = Math.log(secret.noun.length * Score.scales[complexity.to_sym]) * 100
    end
  end

end
