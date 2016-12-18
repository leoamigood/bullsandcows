FactoryGirl.define do
  factory :dictionary_level

  trait :easy_en do
    lang 'EN'
    complexity 'easy'
    min_level 1
    max_level 6
  end

  trait :easy_ru do
    lang 'RU'
    complexity 'easy'
    min_level 1
    max_level 2
  end

  trait :medium_en do
    lang 'EN'
    complexity 'medium'
    min_level 7
    max_level 9
  end

  trait :medium_ru do
    lang 'RU'
    complexity 'medium'
    min_level 3
    max_level 4
  end

  trait :hard_en do
    lang 'EN'
    complexity 'hard'
    min_level 10
    max_level 15
  end

  trait :hard_ru do
    lang 'RU'
    complexity 'hard'
    min_level 3
    max_level 5
  end
end
