require 'airbrake'

class Hooks::FacebookController < BaseApiController
  Rails.logger = Logger.new(STDOUT)
  def create
    render plain: params['hub.challenge']
  end
  def index
    render plain: params['hub.challenge']
  end
end
