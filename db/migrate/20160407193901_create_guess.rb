class CreateGuess < ActiveRecord::Migration[5.1]
  def change
    create_table :guesses do |t|
      t.integer :game_id
      t.string  :word
      t.integer :bulls
      t.integer :cows
      t.integer :attempts, default: 0
      t.boolean :exact

      t.timestamps null: false
    end
  end
end
