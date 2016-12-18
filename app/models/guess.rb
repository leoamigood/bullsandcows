class Guess < ActiveRecord::Base
  include Comparable

  belongs_to :game, counter_cache: true

  def <=>(other)
    score = other.bulls * 3 + other.cows <=> bulls * 3 + cows
    score == 0 ? (self.created_at <=> other.created_at) : score
  end
end
