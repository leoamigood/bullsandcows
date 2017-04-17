class EventSubscriptions
  class << self
    def subscribe
      EventBus.subscribe(Events::GAME_FINISHED, GameStatusEventHandler, :game_finished)
    end
  end
end

EventSubscriptions.subscribe
