class Noun < ActiveRecord::Base
  belongs_to :dictionary

  scope :active, -> { joins(:dictionary).where(excluded: false, dictionaries: {enabled: true}) }

end