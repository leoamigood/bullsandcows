require 'aspector'

module Telegram
  module Action

    class Guess
      class << self
        def execute(channel, user, word)
          game = GameService.find_by_channel!(channel)
          guess = GameEngineService.guess(game, user, word)

          EventBus.announce(Events::GAME_FINISHED, game: game) if game.finished?

          TelegramMessenger.guess(guess)
        end

        private

        def command
          Command::GUESS
        end
      end
    end

    Rules::PermitExecute.apply(Guess, class_methods: true)
  end
end
