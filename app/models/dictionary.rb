class Dictionary < ActiveRecord::Base
  enum lang: {:EN => 'EN', :RU => 'RU'}

  has_many :nouns

  scope :lang, -> (lang) { where(lang: lang.upcase) }
  scope :enabled, -> { where(enabled: true) }
end