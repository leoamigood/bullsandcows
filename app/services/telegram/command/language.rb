module Telegram
  module Command

    class Language
      class << self
        def execute(channel, command)
          language = GameEngineService.get_language_or_default(command.upcase)
          dictionary = Dictionary.where(lang: language).order('RANDOM()').first

          GameEngineService.settings(channel, {dictionary_id: dictionary.id, language: language})
          TelegramMessenger.language(language)
        end
      end
    end

  end
end
