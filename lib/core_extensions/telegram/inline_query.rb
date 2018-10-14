module CoreExtensions
  module Telegram
    module InlineQuery
      include Executor

      def handle
        return ::Telegram::TelegramMessenger.howto(id) unless query.present?

        word = GameService.sanitize(query)
        words = Noun.active.where(noun: word)
        return unless words.present?

        ::Telegram::TelegramMessenger.query(id, words)

        user = UserService.create_from_telegram(from)
        ::Telegram::CommandQueue::UserQueue.new(user).reset.push("/create #{word}")
      end

      def chat_id
        nil
      end
    end
  end
end
