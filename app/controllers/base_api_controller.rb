class BaseApiController < ApplicationController
  before_action :set_default_response_format

  rescue_from Errors::ValidationException do |ex|
    render json: { error: ex.message }, status: 500
  end

  rescue_from Errors::GameNotFoundException do |ex|
    render json: { error: ex.message }, status: 404
  end

  rescue_from Errors::GameNotStartedException do |ex|
    render json: { game_link: Responses::Game.link(ex.game), error: ex.message }, status: 500
  end

  def set_default_response_format
    request.format = :json
  end

  def set_timezone
    Time.zone = 'UTC'
  end

end
