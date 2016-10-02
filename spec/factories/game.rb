FactoryGirl.define do
  factory :game

  trait :with_tries do
    after :create do |game|
      FactoryGirl.create(:guess, word: 'tomato', game: game, bulls: 0, cows: 1)
      FactoryGirl.create(:guess, word: 'mortal', game: game, bulls: 0, cows: 2)
      FactoryGirl.create(:guess, word: 'combat', game: game, bulls: 1, cows: 1)
      FactoryGirl.create(:guess, word: 'ballad', game: game, bulls: 0, cows: 0)
      FactoryGirl.create(:guess, word: 'energy', game: game, bulls: 1, cows: 2)
      FactoryGirl.create(:guess, word: 'sector', game: game, bulls: 3, cows: 2)
      FactoryGirl.create(:guess, word: 'quorum', game: game, bulls: 0, cows: 0)
      FactoryGirl.create(:guess, word: 'master', game: game, bulls: 1, cows: 3)
      FactoryGirl.create(:guess, word: 'engine', game: game, bulls: 1, cows: 2)
      FactoryGirl.create(:guess, word: 'staple', game: game, bulls: 1, cows: 2)
    end
  end
end
