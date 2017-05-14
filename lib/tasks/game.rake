namespace :game do
  task :score  => :environment do
    puts 'Loading games...'
    games = Game.order(created_at: :asc)
    games.each_with_index do |game, i|
      next unless game.level.present?

      ScoreService.create(game) unless game.score.present?
      game.reload # need to link created score to the game
      GameService.score(game) if game.finished? && game.winner_id.present?

      print "Updating score for game #{i} of #{games.count}\r"
    end
    puts "\n"
  end
end
