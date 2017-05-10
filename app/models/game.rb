class Game < ActiveRecord::Base
  belongs_to :creator, class_name: 'User', primary_key: 'ext_id', foreign_key: 'winner_id'
  belongs_to :winner, class_name: 'User', primary_key: 'ext_id', foreign_key: 'winner_id'
  belongs_to :dictionary

  has_many :guesses do
    def since(time)
      guesses = self.select { |guess|
        guess.created_at > time.to_datetime
      } if time.present?

      return guesses || self.all
    end
  end

  has_many :hints
  has_one  :score

  enum status: { created: 'created', running: 'running', finished: 'finished', aborted: 'aborted' }
  enum source: { telegram: 'telegram', web: 'web' }

  scope :recent, -> (channel, since) { where(channel: channel, :created_at => since..Time.now) }

  def best(limit = nil)
    guesses.sort.first(limit || 8)
  end

  def zero(limit = nil)
    guesses.where(bulls: 0, cows: 0).first(limit || 5)
  end

  def in_progress?
    self.created? || self.running?
  end

  def complexity
    return :easy unless level.present?

    DictionaryLevel
        .where(dictionary_id: dictionary_id)
        .where("#{level} >= min_level AND #{level} <= max_level")
        .take.try(:complexity)
  end

end
