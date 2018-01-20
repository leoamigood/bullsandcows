module CoreExtensions
  module Telegram
    module InlineQuery
      include Executor

      def handle
        return ::Telegram::TelegramMessenger.howto(id) unless query.present?

        query = GameService.sanitize(query)
        words = Noun.active.where(noun: query)
        return unless words.present?

        ::TelegramMessenger.query(id, words)

        user = UserService.create_from_telegram(from)
        ::Telegram::CommandQueue::UserQueue.new(user).reset.push("/create #{query}")
      end
    end
  end
end
