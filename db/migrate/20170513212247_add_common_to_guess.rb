class AddCommonToGuess < ActiveRecord::Migration
  def change
    add_column :guesses, :common, :boolean

    Guess.where(common: nil).each do |guess|
      guess.common = Noun.exists?(noun: guess.word)
      guess.save!
    end
  end
end
