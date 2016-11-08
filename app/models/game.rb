class Game < ActiveRecord::Base
  has_many :guesses
  belongs_to :dictionary

  enum status: [:created, :running, :finished, :aborted]
  enum source: { telegram: 'telegram', web: 'web' }

  def best(limit = nil)
    limit.present? ? guesses.sort.first(limit.to_i) : guesses
  end

  def zero(limit = nil)
    limit.present? ? guesses.where(bulls: 0, cows: 0).first(limit.to_i) : guesses.where(bulls: 0, cows: 0)
  end

  def in_progress?
    self.created? || self.running?
  end

  private

  def limit

  end
end
