FactoryGirl.define do
  factory :game do
    factory :finished_game, :traits => [:with_tries, :winning_guess] do
      transient do
        exact_guess nil
      end
    end
  end

  trait :realm do
    initialize_with do
      new(channel: realm.channel, user_id: realm.user.ext_id, source: realm.source)
    end
  end

  trait :created do
    status :created
  end

  trait :running do
    status :running
  end

  trait :finished do
    status :finished
  end

  trait :aborted do
    status :aborted
  end

  trait :with_exact_guess do
    after :create do |game|
      FactoryGirl.create(:guess, word: 'hostel', game: game, user_id: game.user_id, bulls: 6, cows: 0)
    end
  end

  trait :with_tries do
    before :create do |game|
      time = Time.now
      FactoryGirl.create(:guess, word: 'tomato', game: game, bulls: 0, cows: 1, created_at: time - 9.seconds)
      FactoryGirl.create(:guess, word: 'mortal', game: game, bulls: 0, cows: 2, created_at: time - 8.seconds)
      FactoryGirl.create(:guess, word: 'combat', game: game, bulls: 1, cows: 1, created_at: time - 7.seconds)
      FactoryGirl.create(:guess, word: 'ballad', game: game, bulls: 0, cows: 0, created_at: time - 6.seconds)
      FactoryGirl.create(:guess, word: 'energy', game: game, bulls: 1, cows: 2, created_at: time - 5.seconds)
      FactoryGirl.create(:guess, word: 'sector', game: game, bulls: 3, cows: 2, created_at: time - 4.seconds)
      FactoryGirl.create(:guess, word: 'quorum', game: game, bulls: 0, cows: 0, created_at: time - 3.seconds)
      FactoryGirl.create(:guess, word: 'master', game: game, bulls: 1, cows: 3, created_at: time - 2.seconds)
      FactoryGirl.create(:guess, word: 'engine', game: game, bulls: 1, cows: 2, created_at: time - 1.seconds)
      FactoryGirl.create(:guess, word: 'staple', game: game, bulls: 1, cows: 2, created_at: time)
    end
  end

  trait :winning_guess do
    status :finished
    before :create do |game, evaluator|
      game.guesses << evaluator.exact_guess if evaluator.exact_guess.present?
    end
  end

  trait :with_hints do
    before :create do |game|
      FactoryGirl.create(:hint, game: game, letter: 'o', hint: 'o')
      FactoryGirl.create(:hint, game: game, letter: 'a', hint: nil)
      FactoryGirl.create(:hint, game: game, letter: nil, hint: 's')
    end
  end
end
