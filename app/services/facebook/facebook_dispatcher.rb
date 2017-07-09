require 'airbrake'

module Facebook
  class FacebookDispatcher
    class << self
      def execute(command, sender, message)
        puts "Command: #{command}, channel: #{sender['id']}, message: #{message.to_json}"

        case command
          when Telegram::CommandRoute::START
            Telegram::Action::Start.execute(channel, $~['prologue'])
            CommandQueue::Queue.new(channel).execute

          when Telegram::CommandRoute::LANG
            Telegram::Action::Language.ask(channel)

          when Telegram::CommandRoute::LANG_ALPHA
            Telegram::Action::Language.execute(channel, $~['language'])

          when Facebook::CommandRoute::CREATE
            Facebook::Action::Create.ask(message)

          when Facebook::CommandRoute::CREATE_ALPHA
            CommandQueue::Queue.new(channel).reset
            Facebook::Action::Create.execute(channel, user, word: $~['secret'], strategy: :by_word)

          when Telegram::CommandRoute::CREATE_DIGIT
            CommandQueue::Queue.new(channel).reset
            Telegram::Action::Create.execute(channel, user, length: $~['number'], strategy: :by_number)

          when Telegram::CommandRoute::GUESS
            Telegram::Action::Guess.execute(channel, user, $~['guess'])

          when Facebook::CommandRoute::WORD
            # Facebook::Action::Guess.execute(sender, command) if GameService.in_progress?(sender['id'])

          when Telegram::CommandRoute::HINT_ALPHA
            Telegram::Action::Hint.execute(channel, letter: $~['letter'], strategy: :by_letter)

          when Telegram::CommandRoute::HINT_DIGIT
            Telegram::Action::Hint.execute(channel, number: $~['number'], strategy: :by_number)

          when Telegram::CommandRoute::SUGGEST
            Telegram::Action::Suggest.execute(channel, user, $~['letters'])

          when Telegram::CommandRoute::TRIES
            Telegram::Action::Tries.execute(channel)

          when Telegram::CommandRoute::BEST
            Telegram::Action::Best.execute(channel, $~['best'])

          when Telegram::CommandRoute::ZERO
            Telegram::Action::Zero.execute(channel)

          when Telegram::CommandRoute::LEVEL
            Telegram::Action::Level.ask(channel)

          when Telegram::CommandRoute::LEVEL_ALPHA
            Telegram::Action::Level.execute(channel, $~['level'])

          when Telegram::CommandRoute::RULES
            return TelegramMessenger.rules

          when Telegram::CommandRoute::SCORE
            return Telegram::Action::Score.execute(channel), 'HTML'

          when Telegram::CommandRoute::TREND
            return Telegram::Action::Trend.execute(channel, $~['since'] || 'day'), 'HTML'

          when Telegram::CommandRoute::STOP
            Telegram::Action::Stop.execute(channel, message)

          when Telegram::CommandRoute::HELP
            TelegramMessenger.help

          when Telegram::CommandRoute::OTHER
            TelegramMessenger.unknown_command(message)

          when nil
            if message.voice.present?
              command = Telegram::Action::Voice.execute(channel, user, message.voice)
              execute(command, channel, message) if command.present?
            end
        end
      end
    end
  end
end
