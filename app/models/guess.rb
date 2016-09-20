class Guess < ActiveRecord::Base
  include Comparable

  belongs_to :game

  def <=>(other)
    bulls * 3 + cows <=> other.bulls * 3 + other.cows
  end
end