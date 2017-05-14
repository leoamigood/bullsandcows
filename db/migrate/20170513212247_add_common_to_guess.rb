class AddCommonToGuess < ActiveRecord::Migration
  def change
    add_column :guesses, :common, :boolean
  end
end
