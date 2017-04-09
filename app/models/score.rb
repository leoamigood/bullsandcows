class Score < ActiveRecord::Base
  belongs_to :game

  enum scale: { easy: 1.0, medium: 1.15, hard: 1.3 }
end
