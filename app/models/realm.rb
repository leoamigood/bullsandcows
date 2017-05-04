module Realm
  class Base
    vattr_initialize :channel, :user, :source
  end

  class Web < Base
    def initialize(session)
      super(session.id, UserService.create_from_web(session), :web)
    end
  end

  class Telegram < Base
    def initialize(channel, user)
      super(channel, user, :telegram)
    end
  end

end

