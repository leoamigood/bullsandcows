class Dictionary < ApplicationRecord
  enum lang: {:EN => 'EN', :RU => 'RU', :IT => 'IT', :DE => 'DE', :FR => 'FR'}
  enum region: {:en => 'US', :ru => 'RU', :it => 'IT', :de => 'DE', :fr => 'FR'}

  has_many :nouns
  has_many :levels, :class_name => :DictionaryLevel

  scope :enabled, -> { where(enabled: true) }
end
