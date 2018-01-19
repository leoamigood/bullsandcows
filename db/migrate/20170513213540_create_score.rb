class CreateScore < ActiveRecord::Migration[5.1]
  def change
    create_table :scores do |t|
      t.integer :game_id
      t.string  :channel
      t.integer :winner_id
      t.integer :worth
      t.integer :bonus, default: 0
      t.integer :penalty, default: 0
      t.integer :points, default: 0
      t.integer :total, default: 0

      t.timestamps null: false
    end
  end
end
