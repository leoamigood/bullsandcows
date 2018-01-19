class AddHintsCounterToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :hints, :integer, after: :status, default: 0
  end
end
