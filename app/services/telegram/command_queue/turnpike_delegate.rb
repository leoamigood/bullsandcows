require 'turnpike'

module Telegram

  module CommandQueue
    class TurnpikeDelegate
      def initialize(channel)
        @queue = Turnpike.call(channel)
      end
      
      def push(*elements)
        @queue.push(*elements)
      end

      def size
        @queue.size
      end

      def empty?
        @queue.size == 0
      end

      def present?
        @queue.size > 0
      end

      def pop
        unpack(@queue.pop)
      end

      def peek
        element = @queue.pop
        @queue.unshift(element) if element.present?

        unpack(element)
      end

      def clear
        @queue.pop(@queue.size)
      end

      private

      def unpack(msg)
        return unless msg.present?

        classname, command, args, callback = *msg
        Object::const_get(classname).new(command, args, eval(callback.to_s))
      end
    end
  end

end
