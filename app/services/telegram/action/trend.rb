module Telegram
  module Action

    class Trend
      class << self
        def execute(channel, since)
          scores = GameEngineService.trends(channel, eval("1.#{since}.ago")..Time.now)
          TelegramMessenger.top_trends(scores, since)
        end
      end
    end

  end
end
