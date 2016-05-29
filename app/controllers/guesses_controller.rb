class GuessesController < BaseApiController

  def create
    game = Game.find_by_id!(validate[:game_id])
    guess = GameService.guess(game, validate[:username], validate[:guess])

    render json: guess
  end

  private

  def validate
    params.permit(:game_id, :username, :guess)
  end
end