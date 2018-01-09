module CoreExtensions
  module Telegram
    module Message
      include Executor

      def handle
        command = nil

        if text.present?
          command = text.mb_chars.downcase.to_s
        end

        execute(command, chat.id)
      end
    end
  end
end
