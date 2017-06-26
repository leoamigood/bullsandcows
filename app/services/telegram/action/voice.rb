require 'aspector'
require 'open-uri'

module Telegram
  module Action

    class Voice
      class << self
        def execute(channel, user, voice)
          data = TelegramMessenger.loadFile(voice.file_id)

          result = GoogleCloudService.recognize(data, languageRegion(channel, user))
          Rails.logger.info("CHANNEL: #{channel}, TRANSCRIBED AS: #{result}")
          result
        end

        def languageRegion(channel, user)
          lang = GameService.current_game(channel).dictionary.lang.downcase

          if user.language.present?
            user.language.start_with?(lang) ? user.language : bcp47(lang)
          else
            bcp47(lang)
          end
        end

        def bcp47(lang)
          "#{lang}-#{Dictionary.regions[lang]}"
        end
      end
    end

    private
    
    aspector(Voice, class_methods: true) do
      target do
        def permit(*args, &block)
          channel, user, voice = *args
          raise Errors::GameNotRunningException.new(
              "Use voice messages ONLY as a guess word. Please _#{Command::START}_ new game and try again."
          ) unless GameService.current_game(channel).present?

          raise Errors::VoiceMessageException.new(
              'Voice message is too long. Please keep messages under 15 seconds.'
          ) unless voice.duration < 15
        end
      end

      before :execute, :permit
    end
  end
end
