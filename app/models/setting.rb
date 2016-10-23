class Setting < ActiveRecord::Base
  belongs_to :dictionary

  enum complexity: { easy: 'easy', medium: 'medium', hard: 'hard' }
end
