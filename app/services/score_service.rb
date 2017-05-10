class ScoreService

  class << self
    def create(game)
      Score.create(game_id: game.id, channel: game.channel, worth: worth(game.secret, game.complexity))
    end

    def total(game)
      Score
          .where('created_at < ?', game.score.created_at)
          .where(channel: game.channel, winner_id: game.winner_id)
          .sum(:points) + game.score.points
    end

    def points(game)
      [game.score.worth + bonus(game) - penalty(game), 0].max
    end

    def bonus(game)
      user_guesses, others = game.guesses.partition { |g| g.user_id == game.winner_id }
      return 0 if others.empty?

      ratio = (others.count.to_f / others.group_by(&:user_id).count - user_guesses.count) / game.guesses.count
      ([ratio, 0].max * game.score.worth).round
    end

    def penalty(game, severity = 2.0)
      ratio = game.hints.count.to_f / game.secret.length * severity
      [ratio * game.score.worth, game.score.worth + bonus(game)].min.round
    end

    def worth(secret, complexity, scale = 100.0)
      (Math.log(secret.length * Score.complexity_ratios[complexity.to_sym]) * scale).to_i
    end
  end

end
