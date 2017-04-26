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
      end
    end

    aspector(Guess, class_methods: true) do
      target do
        def permit(*args, &block)
          channel = *args
          Telegram::Validator.validate!(Command::GUESS, channel)
        end
      end

      before :execute, :permit
    end
  end
end
