module Telegram
  module Action

    module Rules
      class PermitExecute < Aspector::Base
        before :execute do |*args|
          channel, message = *args
          Telegram::Validator.validate!(command, channel, message)
        end
      end
    end

  end
end



