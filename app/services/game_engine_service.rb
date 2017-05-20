class GameEngineService

  @@RECENT_GAMES_DAYS = 7.days

  class << self
    def create_by_word(realm, input)
      secret = GameService.sanitize(input)

      GameService.create(realm, Noun.new(noun: secret))
    end

    def create_by_options(realm, options)
      secret = secret_by_options(realm, options)
      raise Errors::GameCreateException.new('Unable to create game. Please try different parameters') unless secret.present?

      GameService.create(realm, secret)
    end

    def guess(game, user, input)
      GameService.validate_guess!(game, input)

      word = GameService.sanitize(input)
      GameService.guess(game, user, word)
    end

    def hint(game, letter = nil)
      GameService.hint(game, letter)
    end

    def suggest(game, user, letters = nil)
      nouns = Noun.
          where(dictionary_id: game.dictionary_id).
          where('char_length(noun) = ?', game.secret.length).
          where("noun <> '#{game.secret}'")

      nouns = nouns.where("noun ILIKE '%#{letters}%'") if letters.present?
      suggestion = nouns.order('RANDOM()').first

      GameService.guess(game, user, suggestion.noun, suggestion = true) if suggestion.present?
    end

    def tries(channel)
      game = GameService.find_by_channel!(channel)
      game.guesses.sort_by{ |guess| guess.created_at }
    end

    def best(channel, limit)
      game = GameService.find_by_channel!(channel)
      game.best(limit.try(:to_i))
    end

    def zero(channel)
      game = GameService.find_by_channel!(channel)
      game.zero
    end

    def language(language)
      lang = Dictionary.langs[language]
      raise "Language: #{language} is not available!" unless lang.present?

      lang
    end

    def scores(channel, period = 1.month.ago..Time.now, limit = 8)
      score_sql(channel, period, 'max(total)', limit)
    end

    def score_sql(channel, period, aggregation, limit)
      query = <<-SQL
        SELECT
          first_name,
          last_name,
          username,
          total_score
        FROM (SELECT
                winner_id,
                #{aggregation} AS total_score
              FROM scores
              WHERE channel = '#{channel}' 
              AND created_at BETWEEN '#{period.first.utc}' AND '#{period.last.utc}'
              AND winner_id IS NOT NULL
              GROUP BY (winner_id)
              HAVING #{aggregation} > 0
             ) AS winners
          INNER JOIN users ON winner_id = users.ext_id
          ORDER BY total_score DESC 
          LIMIT #{limit}
      SQL

      ActiveRecord::Base.connection.execute(query).to_a
    end

    def trends(channel, period = 1.week.ago..Time.now, limit = 8)
      score_sql(channel, period, 'max(total) - min(total)', limit)
    end

    def settings(channel, attributes)
      setting = Setting.find_or_create_by!(channel: channel)

      setting.attributes = attributes
      setting.save!

      setting
    end

    private

    def secret_by_options(realm, options)
      nouns = Noun.active.
          by_length(options[:length]).
          in_language(options[:language]).
          by_complexity(options[:language], options[:complexity]).
          order('RANDOM()')

      recent_secrets = Game.recent(realm.channel, Time.now - @@RECENT_GAMES_DAYS).pluck(:secret)
      nouns.detect { |n|
        recent_secrets.exclude?(n.noun)
      } || nouns.first
    end

  end

end
