module Telegram
  module Action

    class Score
      class << self
        def execute(channel)
          scores = GameEngineService.scores(channel)
          TelegramMessenger.top_scores(scores)
        end
      end
    end

  end
end
