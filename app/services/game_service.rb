class GameService

  def GameService.create(secret)
    Game.create({secret: secret})
  end

end