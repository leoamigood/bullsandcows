class MigrateGameStatus < ActiveRecord::Migration
  def change
    Game.where(status: '0').update_all(status: Game.statuses[:created])
    Game.where(status: '1').update_all(status: Game.statuses[:running])
    Game.where(status: '2').update_all(status: Game.statuses[:finished])
    Game.where(status: '3').update_all(status: Game.statuses[:aborted])

    change_column_default :games, :status, :created
  end
end
