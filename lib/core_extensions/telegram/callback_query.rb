require 'core_extensions/telegram/executor'

module CoreExtensions
  module Telegram
    module CallbackQuery
      include Executor

      def handle
        channel = message.chat.id
        command = data.downcase.to_s
        response = execute(command, channel)

        ::Telegram::TelegramMessenger.answerCallbackQuery(id, response)

        queue = ::Telegram::CommandQueue::Queue.new(channel)
        queue.present? ? queue.execute : response
      end
    end
  end
end
