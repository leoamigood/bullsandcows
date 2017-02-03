class GamesController < BaseApiController
  include Rails::Pagination

  def create
    if params[:secret].present?
      game = GameEngineService.create_by_word(session[:id], :web, validate_create[:secret])
      render json: { game: Responses::Game.new(game) }
    else
      game = GameEngineService.create_by_options(session[:id], :web, validate_create_by_options)
      render json: { game: Responses::Game.new(game) }
    end
  end

  def index
    options = { status: validate_index[:status], source: validate_index[:source] }
    games = paginate GameService.find_games(options)
    render json: { games: games.map {|game| Responses::Game.new(game)} }
  end

  def show
    game = GameService.find_by_id!(validate_show[:id])
    render json: { game: Responses::Game.new(game) }
  end

  def update
    game = Game.find_by_id(validate_update[:id])
    status = validate_update[:status]

    case Game.statuses[status]
      when Game.statuses[:aborted]
        GameService.stop!(game)
        render json: { game: Responses::Game.new(game) }
    end

  end

  private

  def validate_create
    params.permit(:secret)
  end

  def validate_create_by_options
    params.require(:length)
    params.require(:language)
    params.require(:complexity)
    params.permit(:length, :language, :complexity)
  end

  def validate_index
    params.permit(:source, :status)
  end

  def validate_show
    params.permit(:id)
  end

  def validate_update
    params.permit(:id, :status)
  end

end
