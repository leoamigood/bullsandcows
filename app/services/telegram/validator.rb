module Telegram
  class Validator
    class << self
      def permitted?(game, action, message)
        case action
          when :stop
            member = TelegramMessenger.getChatMember(message.chat.id, message.from.id)

            if (message.chat.type == 'group')
              status = member['result']['status']
              status == 'creator' || status == 'administrator' || game.user_id == message.from.id
            else
              true
            end
          else
            false
        end
      end
    end
  end
end
