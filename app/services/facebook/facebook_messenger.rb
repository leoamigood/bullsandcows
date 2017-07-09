module Facebook
  class FacebookMessenger

    class << self
      def ask_length(message)
        replies = (4..8).map { |n|
           { content_type: 'text', title: "#{n}", payload: "/create #{n}" }
        }

        message.reply(text: 'How many letters will it be?', quick_replies: replies)
      end
    end

  end
end
