class Noun < ActiveRecord::Base
  belongs_to :dictionary

  scope :active, -> { joins(:dictionary).where(excluded: false, dictionaries: {enabled: true}) }
  scope :in_language, -> (language) { joins(:dictionary).where(dictionaries: {lang: language}) }

end
