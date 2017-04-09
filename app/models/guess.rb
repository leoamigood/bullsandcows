class Guess < ActiveRecord::Base
  include Comparable

  belongs_to :game, counter_cache: true

  def <=>(other)
    points = other.value <=> value
    points == 0 ? (self.created_at <=> other.created_at) : points
  end

  def self.since(time)
    guesses = @relation.select { |guess|
      guess.created_at >= time.to_datetime
    } if time.present?

    return guesses || @relation
  end

  def value
    bulls * 3 + cows
  end

  def ==(other)
    self.eql?(other)
  end
end
