class DictionaryLevel < ApplicationRecord

  def levels
    min_level..max_level
  end

end
