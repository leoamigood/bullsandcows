module Telegram
  class CommandQueue
    @queue = []

    class << self
      def push(&block)
        @queue.push(block)
      end

      def pop
        @queue.pop
      end

      def execute
        shift.try(:call)
      end

      def shift
        @queue.shift
      end

      def size
        @queue.size
      end

      def clear
        @queue.clear
      end

      def empty?
        @queue.empty?
      end
    end
  end
end
