require 'aspector'

module Telegram
  module Command

    class Language
      class << self
        def ask(channel)
          TelegramMessenger.ask_language(channel)
        end

        def execute(channel, language)
          return unless Telegram::CommandQueue.assert(self)

          language = GameEngineService.language(language.upcase)
          dictionary = Dictionary.where(lang: language).order('RANDOM()').first

          GameEngineService.settings(channel, {dictionary_id: dictionary.id, language: language})
          TelegramMessenger.language(language)
        end
      end
    end

    aspector(Language, class_methods: true) do
      target do
        def permit(*args, &block)
          channel, message = *args
          Telegram::Validator.validate!(Action::LANG, channel, message)
        end
      end

      before :ask, :execute, :permit
    end
  end
end
