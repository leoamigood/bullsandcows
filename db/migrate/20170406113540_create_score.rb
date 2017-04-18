class CreateScore < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.integer :game_id
      t.integer :worth
      t.integer :bonus, default = 0
      t.integer :penalty, default = 0
      t.integer :points

      t.timestamps null: false
    end
  end
end
