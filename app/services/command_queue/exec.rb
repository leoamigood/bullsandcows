module CommandQueue
  class Exec
    attr_accessor :command, :args, :callback

    def initialize(command, args, callback = nil)
      @command = command
      @args = args
      @callback = callback
    end

    def call
      eval "#{@command}(#{@args})"
    end

    # called upon redis push message serialization
    def to_msgpack(packer)
      packer.write([self.class.name, @command, *@args, @callback])
    end

    def ==(other)
      self.command == other.command && self.args == other.args && self.callback == other.callback
    end
  end
end
