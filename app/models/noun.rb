class Noun < ActiveRecord::Base
  belongs_to :dictionary

  scope :active, -> { joins(:dictionary).where(excluded: false, dictionaries: {enabled: true}) }

  scope :by_length, -> (length) { where("CHAR_LENGTH(noun) = #{length}") }
  scope :in_language, -> (language) { joins(:dictionary).where(dictionaries: {lang: language}) }
  scope :by_complexity, -> (complexity) { where(:level => DictionaryLevel.find_by_complexity!(complexity).levels) }

end
