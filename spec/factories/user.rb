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

  trait :chris_pooh do
    username 'chris_pooh'
    first_name 'Chris'
    last_name nil
  end

  trait :josef_gold do
    username 'josef_gold'
    first_name 'Josef'
    last_name 'Gold'
  end
end
