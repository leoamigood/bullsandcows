class Dictionary < ActiveRecord::Base
  enum lang: [:EN, :RU]

  belongs_to :dictionary

  scope :lang, -> (lang) { where(lang: lang.upcase) }
end