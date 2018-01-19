module CoreExtensions
  module Telegram
    module Executor
      def execute(command, channel)
        user = UserService.create_from_telegram(from)

        case command
        when ::Telegram::CommandRoute::START
          ::Telegram::Action::Start.execute(channel, $~['prologue'])
          ::Telegram::CommandQueue::Queue.new(channel).execute

        when ::Telegram::CommandRoute::LANG
          ::Telegram::Action::Language.ask(channel)

        when ::Telegram::CommandRoute::LANG_ALPHA
          ::Telegram::Action::Language.execute(channel, $~['language'])

        when ::Telegram::CommandRoute::CREATE
          pre = ::Telegram::CommandQueue::UserQueue.new(user).pop
          pre.present? ? execute(pre, channel) : ::Telegram::Action::Create.ask(channel)

        when ::Telegram::CommandRoute::CREATE_ALPHA
          ::Telegram::CommandQueue::Queue.new(channel).reset
          ::Telegram::Action::Create.execute(channel, user, word: $~['secret'], strategy: :by_word)

        when ::Telegram::CommandRoute::CREATE_DIGIT
          ::Telegram::CommandQueue::Queue.new(channel).reset
          ::Telegram::Action::Create.execute(channel, user, length: $~['number'], strategy: :by_number)

        when ::Telegram::CommandRoute::GUESS
          ::Telegram::Action::Guess.execute(channel, user, $~['guess'])

        when ::Telegram::CommandRoute::WORD
          ::Telegram::Action::Guess.execute(channel, user, command) if GameService.in_progress?(channel)

        when ::Telegram::CommandRoute::HINT_ALPHA
          ::Telegram::Action::Hint.execute(channel, letter: $~['letter'], strategy: :by_letter)

        when ::Telegram::CommandRoute::HINT_DIGIT
          ::Telegram::Action::Hint.execute(channel, number: $~['number'], strategy: :by_number)

        when ::Telegram::CommandRoute::SUGGEST
          ::Telegram::Action::Suggest.execute(channel, user, $~['letters'])

        when ::Telegram::CommandRoute::TRIES
          ::Telegram::Action::Tries.execute(channel)

        when ::Telegram::CommandRoute::BEST
          ::Telegram::Action::Best.execute(channel, $~['best'])

        when ::Telegram::CommandRoute::ZERO
          ::Telegram::Action::Zero.execute(channel)

        when ::Telegram::CommandRoute::LEVEL
          ::Telegram::Action::Level.ask(channel)

        when ::Telegram::CommandRoute::LEVEL_ALPHA
          ::Telegram::Action::Level.execute(channel, $~['level'])

        when ::Telegram::CommandRoute::RULES
          return ::Telegram::TelegramMessenger.rules

        when ::Telegram::CommandRoute::SCORE
          return ::Telegram::Action::Score.execute(channel), 'HTML'

        when ::Telegram::CommandRoute::TREND
          return ::Telegram::Action::Trend.execute(channel, $~['since'] || 'day'), 'HTML'

        when ::Telegram::CommandRoute::STOP
          ::Telegram::Action::Stop.execute(channel, self)

        when ::Telegram::CommandRoute::HELP
          ::Telegram::TelegramMessenger.help

        when ::Telegram::CommandRoute::OTHER
          ::Telegram::TelegramMessenger.unknown_command(self)

        when nil
          if voice.present?
            command = ::Telegram::Action::Voice.execute(channel, user, voice)
            execute(command, channel) if command.present?
          end
        end
      end
    end
  end
end
