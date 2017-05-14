class Score < ActiveRecord::Base
  belongs_to :game
  belongs_to :winner, class_name: 'User', primary_key: 'ext_id', foreign_key: 'winner_id'

  enum complexity_ratio: { easy: 1.0, medium: 1.15, hard: 1.3 }
end
