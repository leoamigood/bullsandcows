module Telegram
  class Validator

    class << self
      include Telegram::Command::Action

      def validate!(action, channel, message)
        game = GameService.recent_game(channel)

        case action
          when START, CREATE
            raise Errors::CommandNotPermittedException.new(
                "You are NOT allowed to _#{action}_ new game. Please finish or _#{STOP}_ current game.", game
            ) if game.try(:in_progress?)
          when LANG
            raise Errors::CommandNotPermittedException.new(
                "You are NOT allowed to change game language. Please finish or _#{STOP}_ current game.", game
            ) if game.try(:in_progress?)

          when LEVEL
            raise Errors::CommandNotPermittedException.new(
                "You are NOT allowed to change game level. Please finish or _#{STOP}_ current game.", game
            ) if game.try(:in_progress?)

          when GUESS, HINT, SUGGEST
            raise Errors::GameNotRunningException.new(
                "Game is not running. Please _#{START}_ new game and try again."
            ) unless game.try(:in_progress?)

          when TRIES, BEST, ZERO
            raise Errors::GameNotRunningException.new(
                "No recent game to show _#{action}_ guesses on. Please _#{START}_ new game and try again."
            ) unless game.present?

          when STOP
            raise Errors::GameNotRunningException.new(
                "No running game to _#{STOP}_. Please _#{START}_ new game and try again."
            ) unless game.try(:in_progress?)
            
            if (message.chat.type == 'group')
              raise Errors::CommandNotPermittedException.new(
                  "You are NOT allowed to _#{STOP}_ this game. Only _admin_ or _game creator_ is.", game
              ) unless permitted?(game, message)
            end
        end

      end

      private

      def permitted?(game, message)
        member = TelegramMessenger.getChatMember(message.chat.id, message.from.id)

        status = member['result']['status']
        status == 'creator' || status == 'administrator' || game.try(:user_id) == message.from.id
      end
    end
  end
end
