class Guess < ApplicationRecord
  include Comparable
  belongs_to :game, counter_cache: true

  after_validation :confirm_noun_existence

  def confirm_noun_existence
    self.common = self.common || Noun.exists?(noun: word)
  end

  def <=>(other)
    points = other.value <=> value
    points == 0 ? (self.created_at <=> other.created_at) : points
  end

  def self.since(time)
    guesses = self.select { |guess|
      guess.created_at > time.to_datetime
    } if time.present?

    guesses || self.all
  end

  def value
    bulls * 3 + cows
  end

  def ==(other)
    self.eql?(other)
  end
end
