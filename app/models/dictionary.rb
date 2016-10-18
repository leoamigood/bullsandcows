class Dictionary < ActiveRecord::Base
  enum lang: {:english => 'EN', :russian => 'RU'}

  has_many :nouns

  scope :enabled, -> { where(enabled: true) }
end
