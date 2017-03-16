class BaseApiController < ApplicationController
  before_action :set_default_response_format

  def realm
    Realm::Web.new(session.id)
  end

  def set_session_realm
    session[:realm] = realm
  end

  rescue_from Errors::ValidationException do |ex|
    render json: { error: ex.message }, status: 500
  end

  rescue_from Errors::GameException do |ex|
    render json: { game_link: Responses::Game.link(ex.game), error: ex.message }, status: 500
  end

  rescue_from Errors::GameNotFoundException do |ex|
    render json: { error: ex.message }, status: 404
  end

  rescue_from ActionController::ParameterMissing do |ex|
    render json: { error: ex.message }, status: 500
  end

  def set_default_response_format
    request.format = :json
  end

  def set_timezone
    Time.zone = 'UTC'
  end

end
