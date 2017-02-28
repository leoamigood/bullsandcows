module Telegram
  class CommandQueue
    @asserted = true
    @commands = []
    @asserts = []

    class << self
      def push(&block)
        @commands.push(block)
        self
      end

      def to_confirm(&block)
        @asserts.push(block)
      end

      def assert(cls)
        @asserted = !!@asserts.first.try(:call, cls)
        @asserts.shift if asserted?

        @asserted
      end

      def asserted?
        @asserted
      end

      def execute
        @asserted = false
        @commands.shift.try(:call)
      end

      def size
        @commands.size
      end

      def clear
        @commands.clear
        @asserts.clear
      end

      def empty?
        @commands.empty?
      end

      def present?
        @commands.present?
      end
    end
  end
end
