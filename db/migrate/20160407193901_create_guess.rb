class CreateGuess < ActiveRecord::Migration
  def change
    create_table :guesses do |t|
      t.integer :game_id
      t.string  :word
      t.integer :bulls
      t.integer :cows
      t.integer :attempts, default: 0
      t.boolean :exact

      t.timestamps nill: false
    end
  end
end
