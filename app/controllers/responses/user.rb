module Responses
  class User < Response

    def initialize(realm)
      @id = realm.user_id
      @link = User.link(realm)
    end

    class << self
      def link(realm)
        "/users/#{realm.user_id}"
      end
    end
  end
end
