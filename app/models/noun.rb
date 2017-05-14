class Noun < ActiveRecord::Base
  belongs_to :dictionary

  scope :active, -> { joins(:dictionary).where(excluded: false, dictionaries: {enabled: true}) }

  scope :by_length, -> (length) { where("CHAR_LENGTH(noun) = #{length}") }
  scope :in_language, -> (language) { joins(:dictionary).where(dictionaries: {lang: language}) }

  scope :by_complexity, -> (language, complexity) {
    where(:level => DictionaryLevel.where(lang: language, complexity: complexity).take.try(:levels))
  }
end
