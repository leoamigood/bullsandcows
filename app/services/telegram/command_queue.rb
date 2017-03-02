module Telegram

  class CommandBlock < Proc
    attr_accessor :callback
  end

  class CommandQueue
    @queue = []
    @asserted = true

    class << self
      def push(&command)
        @queue.push(CommandBlock.new(&command))
        self
      end

      def callback(&callback)
        @queue.last.callback = callback
      end

      def assert(cls)
        return if empty?

        @asserted = !!(peek.callback.try(:call, cls) && shift)
      end

      def asserted?
        @asserted
      end

      def execute
        return unless present? && asserted?

        if peek.callback.present?
          @asserted = false
          peek.call
        else
          shift.call
        end
      end

      def size
        @queue.size
      end

      def clear
        @asserted = true
        @queue.clear
      end

      def empty?
        @queue.empty?
      end

      def present?
        @queue.present?
      end

      private

      def peek
        @queue.first
      end

      def shift
        @queue.shift
      end
    end
  end
end
