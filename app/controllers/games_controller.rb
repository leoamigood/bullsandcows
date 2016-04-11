class GamesController < BaseApiController

  def create
    Rails.logger.info("Creating a games with secret word: #{validate[:secret]}")

    game = GameService.create(validate[:secret])
    render json: game
  end

  def show
    @game = Game.find_by_id!(validate[:id])
  end

  private

  def validate
    params.permit(:secret, :id)
  end
end