module Telegram
  module Command

    class Hint
      class << self
        def execute(channel, letter = nil)
          game = GameService.find_by_channel!(channel)
          hint = GameEngineService.hint(game, letter)
          hint.present? ? TelegramMessenger.hint(hint) : TelegramMessenger.no_hint(letter)
        end
      end
    end

  end
end
