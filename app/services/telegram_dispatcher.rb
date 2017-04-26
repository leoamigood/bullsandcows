require 'airbrake'

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
        return unless message.text.present?

        user = User.find_or_create_by(ext_id: message.from.id) do |user|
          user.ext_id = message.from.id
          user.username = message.from.username
          user.first_name = message.from.first_name
          user.last_name = message.from.last_name
          user.username = message.from.username
          user.source = :telegram
        end

        command = message.text.mb_chars.downcase.to_s
        execute(command, channel = message.chat.id, message, user)
      rescue Errors::GameException => ex
        Airbrake.notify(ex, message.to_h)
        ex.message
      rescue => ex
        Airbrake.notify(ex, message.to_h)
      end
    end

    def handle_callback_query(callback_query)
      begin
        channel = callback_query.message.chat.id
        command = callback_query.data.downcase.to_s
        response = execute(command, channel, callback_query)

        queue = Telegram::CommandQueue::Queue.new(channel)
        if queue.present?
          TelegramMessenger.answerCallbackQuery(callback_query.id, response)
          queue.execute if response.present?
        else
          response
        end
      rescue Errors::GameException => ex
        Airbrake.notify(ex, message.to_h)
        ex.message
      rescue => ex
        Airbrake.notify(ex, message.to_h)
      end

    end

    def execute(command, channel, message, user = nil)
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
    update.inline_query ||
        update.chosen_inline_result ||
        update.callback_query ||
        update.edited_message ||
        update.message
  end

end
