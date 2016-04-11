class GuessesController < BaseApiController

  def create
    Rails.logger.info("Received guess word: #{validate[:guess]}")

    game = Game.find_by_id!(validate[:game_id])
    @guess = GuessService.guess(game, validate[:guess])

    render json: @guess
  end

  private

  def validate
    params.permit(:game_id, :guess)
  end
end