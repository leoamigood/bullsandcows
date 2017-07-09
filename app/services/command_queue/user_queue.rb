module CommandQueue
  class UserQueue < CommandQueue::Queue
    def initialize(user)
      super("user-#{user.ext_id}", BasicTurnpikeDelegate)
    end
  end
end
