class Setting < ApplicationRecord
  belongs_to :dictionary

  enum complexity: { easy: 'easy', medium: 'medium', hard: 'hard' }

  def levels
    return unless dictionary.present?

    level = dictionary.levels.detect{ |level| level.complexity == complexity }
    [*level.min_level..level.max_level]
  end

  def options
    { language: language, complexity: complexity }
  end

end
