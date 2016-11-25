class Dictionary < ActiveRecord::Base
  enum lang: {:EN => 'EN', :RU => 'RU', :IT => 'IT'}

  has_many :nouns
  has_many :levels, :class_name => :DictionaryLevel

  scope :enabled, -> { where(enabled: true) }
end
