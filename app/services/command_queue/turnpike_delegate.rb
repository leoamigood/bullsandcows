module CommandQueue
  class TurnpikeDelegate < BasicTurnpikeDelegate
    def pop
      unpack(@queue.pop)
    end

    def peek
      element = @queue.pop
      @queue.unshift(element) if element.present?

      unpack(element)
    end

    private

    def unpack(msg)
      return unless msg.present?

      classname, command, args, callback = *msg
      Object::const_get(classname).new(command, args, eval(callback.to_s))
    end
  end
end
