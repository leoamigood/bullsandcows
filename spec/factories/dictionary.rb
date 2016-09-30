FactoryGirl.define do
  factory :dictionary do
    enabled true
  end

  trait :basic do
    after :create do |dictionary|
      FactoryGirl.create(:noun, noun: 'secret', dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'tomato', dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'mortal', dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'combat', dictionary: dictionary)
    end
  end

  trait :words_with_levels do
    after :create do |dictionary|
      FactoryGirl.create(:noun, noun: 'secret',    level: 1, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'combat',    level: 2, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'emergency', level: 3, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'tomato',    level: 4, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'ellipse',   level: 5, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'value',     level: 6, dictionary: dictionary)
    end
  end
end