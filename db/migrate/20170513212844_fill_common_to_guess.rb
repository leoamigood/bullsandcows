class FillCommonToGuess < ActiveRecord::Migration
  disable_ddl_transaction!
  def change
    Guess.where(common: nil).each do |guess|
      guess.common = Noun.exists?(noun: guess.word)
      guess.save!
    end
  end
end
