class Dictionary < ActiveRecord::Base
  enum lang: {:EN => 'EN', :RU => 'RU'}

  has_many :nouns

  scope :enabled, -> { where(enabled: true) }
end
