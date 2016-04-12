json.game do
  json.id @game.id
  json.status @game.status
  json.guesses @game.guesses do |guess|
    json.id guess.id
    json.word guess.word
    json.bulls guess.bulls
    json.cows guess.cows
    json.attempts guess.attempts
  end
  json.created @game.created_at
  json.updated @game.updated_at
end
