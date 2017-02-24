class GuessesController < BaseApiController
  include Rails::Pagination

  def create
    game = GameService.find_by_id!(validate[:game_id])
    guess = GameEngineService.guess(game, User.new(id = Random.rand, name = validate[:username]), validate[:guess])

    render json: {
        guess: Responses::Guess.new(guess),
        game_link: Responses::Game.link(game),
        game_stats: Responses::Game.stats(game)
    }
  end

  def index
    game = Game.find_by_id!(validate[:game_id])
    guesses = game.guesses.since(validate[:since])

    render json: { guesses: paginate(guesses).map {|guess| Responses::Guess.new(guess)}, game_link: Responses::Game.link(game) }
  end

  def best
    game = Game.find_by_id!(validate[:game_id])
    guesses = game.best(squash(filter_params[:best], :to_i))

    render json: { best: guesses.map {|guess| Responses::Guess.new(guess)}, game_link: Responses::Game.link(game) }
  end

  def zero
    game = Game.find_by_id!(validate[:game_id])
    guesses = game.zero(squash(filter_params[:zero], :to_i))

    render json: { zero: guesses.map {|guess| Responses::Guess.new(guess)}, game_link: Responses::Game.link(game) }
  end

  private

  def validate
    params.permit(:game_id, :username, :guess, :since)
  end

  def filter_params
    params.permit(:best, :zero)
  end

  def squash(s, method)
    s.empty? ? nil : s.send(method)
  end
end
