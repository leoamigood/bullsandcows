class GuessesController < BaseApiController

  def create
    game = GameService.find_by_id!(validate[:game_id])
    guess = GameEngineService.guess(game, validate[:username], validate[:guess])

    render json: { guess: Responses::Guess.new(guess), game_link: Responses::Game.link(game) }
  end

  def index
    game = Game.find_by_id!(validate[:game_id])

    render json: { guesses: game.guesses.map {|guess| Responses::Guess.new(guess)}, game_link: Responses::Game.link(game) }
  end

  def best
    game = Game.find_by_id!(validate[:game_id])
    guesses = game.best(squash filter_params[:best])

    render json: { best: guesses.map {|guess| Responses::Guess.new(guess)}, game_link: Responses::Game.link(game) }
  end

  def zero
    game = Game.find_by_id!(validate[:game_id])
    guesses = game.zero(squash filter_params[:zero])

    render json: { zero: guesses.map {|guess| Responses::Guess.new(guess)}, game_link: Responses::Game.link(game) }
  end

  private

  def validate
    params.permit(:game_id, :username, :guess)
  end

  def filter_params
    params.permit(:best, :zero)
  end

  def squash(s)
    s.empty? ? nil : s.to_i
  end
end
