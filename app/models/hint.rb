class Hint < ApplicationRecord
  belongs_to :game, counter_cache: true

end
