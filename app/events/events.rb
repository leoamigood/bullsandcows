module Events
  GAME_FINISHED = 'GAME_FINISHED_EVENT'

  EventBus.on_error do |listener, payload|
    Rails.logger.error("Failed at #{listener} with payload #{payload}")
    Airbrake.notify(payload[:error], payload)
  end
end
