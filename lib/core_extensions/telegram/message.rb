module CoreExtensions
  module Telegram
    module Message
      include Executor

      def handle
        command = text.present? ? text.mb_chars.downcase.to_s : nil
        execute(command, chat.id)
      end
    end
  end
end
