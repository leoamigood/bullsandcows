FactoryGirl.define do
  factory :dictionary do
    enabled true
  end

  trait :words_with_levels do
    after :create do |dictionary|
      FactoryGirl.create(:noun, noun: 'secret',    level: 1, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'combat',    level: 2, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'emergency', level: 3, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'tomato',    level: 4, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'ellipse',   level: 5, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'value',     level: 6, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'terminal',  level: 7, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'parrot',    level: 8, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'garlic',    level: 9, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'barrel',    level: 10, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'trooper',   level: 11, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'portal',    level: 12, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'scene',     level: 13, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'knight',    level: 14, dictionary: dictionary)
      FactoryGirl.create(:noun, noun: 'axe',       level: 15, dictionary: dictionary)
    end
  end
end
