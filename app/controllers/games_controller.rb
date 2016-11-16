class GamesController < BaseApiController

  def create
    game = GameEngineService.create_by_word(session.id, validate[:secret], :web)
    render json: { game: Responses::Game.new(game) }
  end

  def index
    options = { status: filter[:status], source: filter[:source] }
    games = GameService.find(options)
    render json: { games: games.map {|game| Responses::Game.new(game)} }
  end

  def show
    game = GameService.find_by_id!(validate[:id])
    render json: { game: Responses::Game.new(game) }
  end

  def update
    game = Game.find_by_id(validate[:id])
    status = validate[:status]

    case Game.statuses[status]
      when Game.statuses[:aborted]
        GameService.stop!(game)
        render json: { game: Responses::Game.new(game) }
    end

  end

  private

  def validate
    params.permit(:id, :secret, :status)
  end

  def filter
    params.permit(:source, :status)
  end

end
