class CreateHint < ActiveRecord::Migration
  def change
    create_table :hints do |t|
      t.integer :game_id
      t.string  :letter
      t.string  :hint

      t.timestamps null: false
    end

    rename_column :games, :hints, :hints_count
  end
end
