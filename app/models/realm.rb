module Realm

  class Base
    vattr_initialize :channel, :user_id, :source
  end

  class Web < Base
    def initialize(session_id)
      super(session_id, session_id, :web)
    end
  end

  class Telegram < Base
    def initialize(channel, user_id)
      super(channel, user_id, :telegram)
    end
  end

end

