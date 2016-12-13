module Telegram
  class Validator
    class << self
      def permitted?(action, message)
        case action
          when :stop
            member = TelegramMessenger.getChatMember(message.chat.id, message.from.id)
            status = member['result']['status']

            message.chat.type == 'group' ? status == 'creator' || status == 'administrator' : status == 'member'
          else
            false
        end
      end
    end
  end
end
