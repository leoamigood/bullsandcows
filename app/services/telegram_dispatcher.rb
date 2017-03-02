class TelegramDispatcher

  class << self
    def update(update)
      payload = extract_message(update)

      case payload
        when Telegram::Bot::Types::Message
          response = handle(payload)
          Telegram::Response.new(payload.chat.id, response)

        when Telegram::Bot::Types::CallbackQuery
          response = handle_callback_query(payload)
          Telegram::Response.new(payload.message.chat.id, response)
      end
    end

    def handle(message)
      begin
        command = message.text.mb_chars.downcase.to_s
        execute(command, message.chat.id, message)
      rescue => ex
        ex.message
      end
    end

    def handle_callback_query(callback_query)
      begin
        command = callback_query.data.downcase.to_s
        response = execute(command, callback_query.message.chat.id, callback_query)

        if Telegram::CommandQueue.present?
          TelegramMessenger.answerCallbackQuery(callback_query.id, response)
          Telegram::CommandQueue.execute
        else
          response
        end
      rescue => ex
        ex.message
      end
    end

    def execute(command, channel, message)
      case command
        when Telegram::CommandRoute::START
          Telegram::Command::Start.execute(channel)
          Telegram::CommandQueue.execute

        when Telegram::CommandRoute::LANG
          Telegram::Command::Language.ask(channel)

        when Telegram::CommandRoute::LANG_ALPHA
          Telegram::Command::Language.execute(channel, $~['language'])

        when Telegram::CommandRoute::CREATE
          Telegram::Command::Create.ask(channel)

        when Telegram::CommandRoute::CREATE_ALPHA
          Telegram::Command::Create.execute(channel, message, word: $~['secret'], strategy: :by_word)

        when Telegram::CommandRoute::CREATE_DIGIT
          Telegram::Command::Create.execute(channel, message, length: $~['number'], strategy: :by_number)

        when Telegram::CommandRoute::GUESS
          Telegram::Command::Guess.execute(channel, message, $~['guess'])

        when Telegram::CommandRoute::WORD
          Telegram::Command::Guess.execute(channel, message, command) if GameService.in_progress?(channel)

        when Telegram::CommandRoute::HINT_ALPHA
          Telegram::Command::Hint.execute(channel, letter: $~['letter'], strategy: :by_letter)

        when Telegram::CommandRoute::HINT_DIGIT
          Telegram::Command::Hint.execute(channel, number: $~['number'], strategy: :by_number)

        when Telegram::CommandRoute::SUGGEST
          Telegram::Command::Suggest.execute(channel, message, $~['letters'])

        when Telegram::CommandRoute::TRIES
          Telegram::Command::Tries.execute(channel)

        when Telegram::CommandRoute::BEST
          Telegram::Command::Best.execute(channel, $~['best'])

        when Telegram::CommandRoute::ZERO
          Telegram::Command::Zero.execute(channel)

        when Telegram::CommandRoute::LEVEL
          Telegram::Command::Level.ask(channel)

        when Telegram::CommandRoute::LEVEL_ALPHA
          Telegram::Command::Level.execute(channel, $~['level'])

        when Telegram::CommandRoute::STOP
          Telegram::Command::Stop.execute(channel, message)

        when Telegram::CommandRoute::HELP
          TelegramMessenger.help

        when Telegram::CommandRoute::OTHER
          TelegramMessenger.unknown_command(message)
      end
    end

  end

  private

  def self.extract_message(update)
    update.inline_query ||
        update.chosen_inline_result ||
        update.callback_query ||
        update.edited_message ||
        update.message
  end

end
