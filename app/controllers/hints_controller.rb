class HintsController < BaseApiController

  def create
    game = GameService.find_by_id!(validate[:game_id])
    hint = GameEngineService.hint(game, validate[:hint])

    render json: { hint: Responses::Hint.new(validate[:hint], hint), game_link: Responses::Game.link(game) }
  end

  private

  def validate
    params.permit(:game_id, :hint)
  end

end
