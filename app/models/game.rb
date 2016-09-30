class Game < ActiveRecord::Base
  has_many :guesses
  belongs_to :dictionary

  enum status: [:created, :running, :finished]
end