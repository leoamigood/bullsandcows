require 'aspector'

module Telegram
  module Action

    class Language
      class << self
        def ask(channel)
          TelegramMessenger.ask_language(channel)
        end

        def execute(channel, language)
          language = GameEngineService.language(language.upcase)
          dictionary = Dictionary.where(lang: language).order('RANDOM()').first

          GameEngineService.settings(channel, {dictionary_id: dictionary.id, language: language})
          TelegramMessenger.language(language)
        end

        def self?
          "proc { |cls| cls == #{self.name} }"
        end
      end
    end

    private

    aspector(Language, class_methods: true) do
      target do
        def assert(*args, &block)
          channel, message = *args
          Telegram::CommandQueue::Queue.new(channel).assert(self)
        end

        def permit(*args, &block)
          channel, message = *args
          Telegram::Validator.validate!(Command::LANG, channel, message)
        end

        def pop(*args, &block)
          msg, channel, message = *args
          Telegram::CommandQueue::Queue.new(channel).pop

          msg
        end
      end

      before_filter :execute, :assert
      before :ask, :execute, :permit
      after :execute, :pop
    end
  end
end
