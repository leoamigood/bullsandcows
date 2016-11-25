FactoryGirl.define do
  factory :dictionary_level

  trait :easy do
    complexity 'easy'
    min_level 1
    max_level 6
  end

  trait :medium do
    complexity 'medium'
    min_level 7
    max_level 9
  end

  trait :hard do
    complexity 'hard'
    min_level 10
    max_level 15
  end
end
