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
    language 'en-GB'
  end

  trait :chris_pooh do
    username 'chris_pooh'
    first_name 'Chris'
    last_name nil
    language nil
  end

  trait :josef_gold do
    username 'josef_gold'
    first_name 'Josef'
    last_name 'Gold'
    language 'en-US'
  end

  trait :pavel_durov do
    username 'pavel_durov'
    first_name 'Pavel'
    last_name 'Durov'
    language 'ru-RU'
  end
end
