require 'aspector'

module Telegram
  module Action

    class Tries
      class << self
        def execute(channel)
          guesses = GameEngineService.tries(channel)
          TelegramMessenger.tries(guesses)
        end

        private

        def command
          Command::TRIES
        end
      end
    end

    Rules::PermitExecute.apply(Tries, class_methods: true)
  end
end
