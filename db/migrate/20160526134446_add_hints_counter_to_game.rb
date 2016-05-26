class AddHintsCounterToGame < ActiveRecord::Migration
  def change
    add_column :games, :hints, :integer, after: :status, default: 0
  end
end
