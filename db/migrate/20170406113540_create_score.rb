class CreateScore < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.integer :game_id
      t.integer :worth
      t.integer :bonus
      t.integer :penalty
      t.integer :points

      t.timestamps null: false
    end
  end
end
