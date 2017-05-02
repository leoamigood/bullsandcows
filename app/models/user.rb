class User < ActiveRecord::Base

  def ==(other)
    id == other.id || ext_id = other.ext_id && source == other.source
  end
end
