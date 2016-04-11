class Game < ActiveRecord::Base
  has_many :guesses
end