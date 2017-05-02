module Responses
  class User < Response

    def initialize(user)
      @id = user.id
      @link = User.link(user)
    end

    class << self
      def link(user)
        "/users/#{user.id}"
      end
    end
  end
end
