require 'aspector'

module Telegram
  module Action

    class Hint
      class << self
        def execute(channel, options)
          game = GameService.find_by_channel!(channel)

          case options[:strategy]
            when :by_letter
              hint = GameEngineService.hint(game, options[:letter])
              hint.present? ? TelegramMessenger.hint(hint) : TelegramMessenger.no_hint(options[:letter])

            when :by_number
              hint = GameService.open(game, options[:number].to_i)
              TelegramMessenger.hint(hint)
          end
        end
      end
    end

    private

    aspector(Hint, class_methods: true) do
      target do
        def permit(*args, &block)
          channel, message = *args
          Telegram::Validator.validate!(Command::HINT, channel, message)
        end
      end

      before :ask, :execute, :permit
    end

  end
end
