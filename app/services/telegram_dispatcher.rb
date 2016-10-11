class TelegramDispatcher

  @@BOT_NAME = 'BullsAndCowsWordsBot'

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
        execute(command, callback_query.message.chat.id, callback_query)
      rescue => ex
        ex.message
      end
    end

    def execute(command, channel, message)
      case command
        when /^\/start/
          TelegramMessenger.welcome(message)

        when /^\/create(?:@#{@@BOT_NAME})?$/i
          game = GameEngineService.create(channel, :telegram)
          TelegramMessenger.game_created(game)

        when /^\/create(?:@#{@@BOT_NAME})? ([[:alpha:]]+)$/i
          game = GameEngineService.create_by_word(channel, $1, :telegram)
          TelegramMessenger.game_created(game)

        when /^\/create(?:@#{@@BOT_NAME})? ([[:digit:]]+)$/i
          game = GameEngineService.create_by_number(channel, $1, :telegram)
          TelegramMessenger.game_created(game)

        when /^\/guess(?:@#{@@BOT_NAME})? ([[:alpha:]]+)$/i
          guess = GameEngineService.guess(channel, message.from.username, $1)
          TelegramMessenger.guess(guess)

        when /^\/hint(?:@#{@@BOT_NAME})?$/i
          letter = GameEngineService.hint(channel)
          TelegramMessenger.hint(letter)

        when /^\/tries(?:@#{@@BOT_NAME})?$/i
          guesses = GameEngineService.tries(channel)
          TelegramMessenger.tries(guesses)

        when /^\/best(?:@#{@@BOT_NAME})?$/i
          guesses = GameEngineService.best(channel)
          TelegramMessenger.best(guesses)

        when /^\/best(?:@#{@@BOT_NAME})? ([[:digit:]]+)$/i
          guesses = GameEngineService.best(channel, $1)
          TelegramMessenger.best(guesses)

        when /^\/zeros(?:@#{@@BOT_NAME})?$/i
          guesses = GameEngineService.zeros(channel)
          TelegramMessenger.zeros(guesses)

        when /^\/level(?:@#{@@BOT_NAME})? ([[:alpha:]]+)$/i
          levels = GameEngineService.level($1)
          TelegramMessenger.level(message, $1)

          game = GameEngineService.create(channel, levels)
          TelegramMessenger.game_created(game)

        when /^\/stop(?:@#{@@BOT_NAME})?$/i
          if GameEngineService.stop_permitted?(message)
            game = GameEngineService.stop(channel)
            TelegramMessenger.game_stop(game)
          else
            TelegramMessenger.no_permissions_to_stop_game
          end

        when /^\/help(?:@#{@@BOT_NAME})?$/i
          TelegramMessenger.help

        when /^\/.*/
          TelegramMessenger.unknown_command(message)

        else
          game = Game.where(channel: channel).last
          if game.present? && !game.finished?
            guess = GameEngineService.guess(channel, message.from.username, command)
            TelegramMessenger.guess(guess)
          else
            TelegramMessenger.new_game?
          end
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
