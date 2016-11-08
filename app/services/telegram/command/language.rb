module Telegram
  module Command

    class Language
      class << self
        def execute(channel, command)
          language = GameEngineService.get_language_or_default(command.upcase)
          GameEngineService.settings(channel, {language: language})
          TelegramMessenger.language(language)
        end
      end
    end

  end
end
