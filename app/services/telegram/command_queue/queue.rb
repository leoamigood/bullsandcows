module Telegram

  module CommandQueue
    class Queue
      def initialize(channel, delegate = TurnpikeDelegate)
        @channel = channel
        @delegate = delegate.new(channel)
      end

      def push(*commands)
        @delegate.push(*commands)
        self
      end

      def assert(cls)
        return true if empty?

        peek.callback.try(:call, cls)
      end

      def pop
        @delegate.pop
      end

      def execute
        return if empty?

        if peek.callback.present?
          peek.try(:call)
        else
          pop.call
        end
      end

      def size
        @delegate.size
      end

      def clear
        @delegate.clear
      end

      def reset
        @delegate.clear
        self
      end

      def present?
        not empty?
      end

      def empty?
        @delegate.empty?
      end

      private

      def peek
        @delegate.peek
      end
    end
  end

end
