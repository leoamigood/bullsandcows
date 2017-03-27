class BaseApiController < ApplicationController
  before_action :set_default_response_format

  def realm
    Realm::Web.new(session.id)
  end

  def set_session_realm
    session[:realm] = realm
  end

  rescue_from Errors::GameException do |ex|
    render json: { game_link: Responses::Game.link(ex.game), error: ex.message }, status: 500
  end

  rescue_from Errors::GameNotFoundException,  with: :log_not_found
  rescue_from ActionController::ParameterMissing, Errors::ValidationException, with: :log_server_error

  def set_default_response_format
    request.format = :json
  end

  def set_timezone
    Time.zone = 'UTC'
  end

  private

  def log_not_found(ex)
    Airbrake.notify(ex)
    render json: { error: ex.message }, status: 404
  end

  def log_server_error(ex)
    Airbrake.notify(ex)
    render json: { error: ex.message }, status: 500
  end

end
