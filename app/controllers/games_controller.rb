class GamesController < BaseApiController

  def create
    Rails.logger.info("Creating a games with secret word: #{validate[:secret]}")

    game = GameService.create(request.session_options[:id], validate[:secret], :web)
    render json: game
  end

  def show
    @game = Game.find_by_id!(validate[:id])
  end

  private

  def validate
    params.permit(:secret, :source, :id)
  end
end