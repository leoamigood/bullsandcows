class AddCommonToGuess < ActiveRecord::Migration[5.1]
  def change
    add_column :guesses, :common, :boolean
  end
end
