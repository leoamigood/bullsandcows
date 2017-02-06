module Telegram
  module Command

    class Hint
      class << self
        def execute_by_letter(channel, letter = nil)
          game = GameService.find_by_channel!(channel)
          hint = GameEngineService.hint(game, letter)
          hint.present? ? TelegramMessenger.hint(hint) : TelegramMessenger.no_hint(letter)
        end
        def execute_by_number(channel, number)
          game = GameService.find_by_channel!(channel)
          hint = GameEngineService.open(game, number.to_i)
          TelegramMessenger.hint(hint)
        end
      end
    end

  end
end
