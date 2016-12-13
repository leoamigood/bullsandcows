class DictionaryLevel < ActiveRecord::Base

  def levels
    min_level..max_level
  end

end
