class Game < ActiveRecord::Base
  has_many :guesses

  enum status: [:created, :running, :finished]
end