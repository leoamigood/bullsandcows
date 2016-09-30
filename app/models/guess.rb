class Guess < ActiveRecord::Base
  include Comparable

  belongs_to :game

  def <=>(other)
    score = other.bulls * 3 + other.cows <=> bulls * 3 + cows
    score == 0 ? (self.created_at <=> other.created_at) : score
  end
end