require 'turnpike'

module Telegram

  module CommandQueue
    class BasicTurnpikeDelegate
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
        @queue.pop
      end

      def peek
        element = @queue.pop
        @queue.unshift(element) if element.present?

        element
      end

      def clear
        @queue.pop(@queue.size)
      end
    end
  end

end
