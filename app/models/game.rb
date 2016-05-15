class Game < ActiveRecord::Base
  has_many :guesses

  enum status: [:created, :running, :finished]

  # scope :attempts, -> { guesses.jnject(0) {|sum, guess| sum + guess.attempt} }
end