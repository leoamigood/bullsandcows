class Noun < ActiveRecord::Base
  enum lang: [:EN, :RU]

  scope :lang, -> (lang) { where(lang: lang.upcase) }
end