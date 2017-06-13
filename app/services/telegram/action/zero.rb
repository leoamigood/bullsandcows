require 'aspector'

module Telegram
  module Action

    class Zero
      class << self
        def execute(channel)
          guesses = GameEngineService.zero(channel)
          TelegramMessenger.zero(guesses)
        end

        private

        def command
          Command::ZERO
        end
      end
    end

    Rules::PermitExecute.apply(Zero, class_methods: true)
  end
end

