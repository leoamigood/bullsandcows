require 'aspector'

module Telegram
  module Action

    class Guess
      class << self
        def execute(channel, message, word)
          game = GameService.find_by_channel!(channel)
          guess = GameEngineService.guess(game, User.new(message.from.id, message.from.username), word)

          EventBus.announce(Events::GAME_FINISHED, game: game) if game.finished?

          TelegramMessenger.guess(guess)
        end
      end
    end

    private
    
    aspector(Guess, class_methods: true) do
      target do
        def permit(*args, &block)
          channel, message = *args
          Telegram::Validator.validate!(Command::GUESS, channel, message)
        end
      end

      before :execute, :permit
    end
  end
end
