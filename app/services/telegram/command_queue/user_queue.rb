module Telegram

  module CommandQueue
    class UserQueue < Telegram::CommandQueue::Queue
      def initialize(user)
        super("user-#{user.ext_id}", BasicTurnpikeDelegate)
      end
    end
  end

end
