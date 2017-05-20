require 'airbrake'

class TelegramDispatcher

  class << self
    def update(update)
      payload, chat_id = extract_message(update)
      begin
        case payload
          when Telegram::Bot::Types::Message
            response, mode = *handle(payload)
            Telegram::Response.new(chat_id, response, mode)

          when Telegram::Bot::Types::CallbackQuery
            response = handle_callback_query(payload)
            Telegram::Response.new(chat_id, response)
        end
      rescue Errors::GameException => ex
        log_error(ex, update)
        Telegram::Response.new(chat_id, ex.message)
      rescue => ex
        log_error(ex, update)
      end
    end

    def log_error(ex, update)
      unless Rails.env == 'test'
        Airbrake.notify_sync(ex, update.to_h)
        Rails.logger.warn("Error: #{ex.message}, Update: #{update.to_json}")
      end
    end

    def handle(message)
      return unless message.text.present?

      command = message.text.mb_chars.downcase.to_s
      execute(command, channel = message.chat.id, message)
    end

    def handle_callback_query(callback_query)
      channel = callback_query.message.chat.id
      command = callback_query.data.downcase.to_s
      response = execute(command, channel, callback_query)

      TelegramMessenger.answerCallbackQuery(callback_query.id, response)
      queue = Telegram::CommandQueue::Queue.new(channel)
      queue.present? ? queue.execute : response
    end

    def execute(command, channel, message)
      user = UserService.create_from_telegram(message)

      case command
        when Telegram::CommandRoute::START
          Telegram::Action::Start.execute(channel)
          Telegram::CommandQueue::Queue.new(channel).execute

        when Telegram::CommandRoute::LANG
          Telegram::Action::Language.ask(channel)

        when Telegram::CommandRoute::LANG_ALPHA
          Telegram::Action::Language.execute(channel, $~['language'])

        when Telegram::CommandRoute::CREATE
          Telegram::Action::Create.ask(channel)

        when Telegram::CommandRoute::CREATE_ALPHA
          Telegram::Action::Create.execute(channel, user, word: $~['secret'], strategy: :by_word)

        when Telegram::CommandRoute::CREATE_DIGIT
          Telegram::Action::Create.execute(channel, user, length: $~['number'], strategy: :by_number)

        when Telegram::CommandRoute::GUESS
          Telegram::Action::Guess.execute(channel, user, $~['guess'])

        when Telegram::CommandRoute::WORD
          Telegram::Action::Guess.execute(channel, user, command) if GameService.in_progress?(channel)

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
          return Telegram::Action::Trend.execute(channel, $~['since'] || 'week'), 'HTML'

        when Telegram::CommandRoute::STOP
          Telegram::Action::Stop.execute(channel, message)

        when Telegram::CommandRoute::HELP
          TelegramMessenger.help

        when Telegram::CommandRoute::OTHER
          TelegramMessenger.unknown_command(message)
      end
    end

  end

  private

  def self.extract_message(update)
    return update.callback_query, update.callback_query.message.chat.id if update.callback_query.present?
    return update.message, update.message.chat.id if update.message.present?
  end

end
