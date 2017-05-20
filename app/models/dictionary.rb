class Dictionary < ApplicationRecord
  enum lang: {:EN => 'EN', :RU => 'RU', :IT => 'IT', :DE => 'DE', :FR => 'FR'}

  has_many :nouns
  has_many :levels, :class_name => :DictionaryLevel

  scope :enabled, -> { where(enabled: true) }
end
