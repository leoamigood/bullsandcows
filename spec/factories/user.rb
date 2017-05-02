FactoryGirl.define do
  factory :user do
    sequence(:ext_id) { generate_random_int }
  end

  trait :telegram do
    source 'telegram'
  end

  trait :web do
    source 'web'
  end

  trait :john_smith do
    username 'john_smith'
    first_name 'John'
    last_name 'Smith'
  end

  trait :player_leo do
    username 'player_leo'
    first_name 'Leo'
    last_name 'Player'
  end
end
