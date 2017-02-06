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

        when Telegram::CommandRoute::LANG
          TelegramMessenger.ask_language(channel)

        when Telegram::CommandRoute::LANG_ALPHA
          Telegram::Command::Language.execute(channel, $~['language'])

        when Telegram::CommandRoute::CREATE
          TelegramMessenger.ask_length(channel)

        when Telegram::CommandRoute::CREATE_ALPHA
          Telegram::Command::Create.execute(channel, $~['secret'], :create_by_word)

        when Telegram::CommandRoute::CREATE_DIGIT
          Telegram::Command::Create.create_by_options(channel, length: $~['number'])

        when Telegram::CommandRoute::GUESS
          Telegram::Command::Guess.execute(channel, message, $~['guess'])

        when Telegram::CommandRoute::HINT_ALPHA
          Telegram::Command::Hint.execute_by_letter(channel, $~['letter'])

        when Telegram::CommandRoute::HINT_DIGIT
          Telegram::Command::Hint.execute_by_number(channel, $~['number'])

        when Telegram::CommandRoute::SUGGEST
          Telegram::Command::Suggest.execute(channel, message, $~['letters'])

        when Telegram::CommandRoute::TRIES
          guesses = GameEngineService.tries(channel)
          TelegramMessenger.tries(guesses)

        when Telegram::CommandRoute::BEST
          guesses = GameEngineService.best(channel, $~['best'].try(:to_i))
          TelegramMessenger.best(guesses)

        when Telegram::CommandRoute::ZERO
          guesses = GameEngineService.zero(channel)
          TelegramMessenger.zero(guesses)

        when Telegram::CommandRoute::LEVEL
          TelegramMessenger.ask_level(channel)

        when Telegram::CommandRoute::LEVEL_ALPHA
          GameEngineService.settings(channel, { complexity: $~['level'] })
          TelegramMessenger.level($~['level'])

        when Telegram::CommandRoute::STOP
          Telegram::Command::Stop.validate(message)
          game = Telegram::Command::Stop.execute(channel)
          TelegramMessenger.game_stop(game)

        when Telegram::CommandRoute::HELP
          TelegramMessenger.help

        when Telegram::CommandRoute::OTHER
          TelegramMessenger.unknown_command(message)

        else
          Telegram::Command::Guess.execute(channel, message, command)
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
