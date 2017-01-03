class Guess < ActiveRecord::Base
  include Comparable

  belongs_to :game, counter_cache: true

  def <=>(other)
    score = other.bulls * 3 + other.cows <=> bulls * 3 + cows
    score == 0 ? (self.created_at <=> other.created_at) : score
  end

  def self.since(time)
    guesses = @relation.select { |guess|
      guess.created_at >= time.to_datetime
    } if time.present?

    return guesses || @relation
  end

  def ==(other)
    self.eql?(other)
  end
end
