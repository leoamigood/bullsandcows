FactoryGirl.define do
  factory :dictionary do
    enabled true
  end

  trait :russian do
    lang 'RU'

    after :create do |dictionary|
      FactoryGirl.create(:noun, noun: 'оборона',   level: 1, dictionary: dictionary) # easy
      FactoryGirl.create(:noun, noun: 'совет',     level: 2, dictionary: dictionary) # easy
      FactoryGirl.create(:noun, noun: 'вопрос',    level: 3, dictionary: dictionary) # medium
      FactoryGirl.create(:noun, noun: 'маргинал',  level: 4, dictionary: dictionary) # medium
      FactoryGirl.create(:noun, noun: 'джезва',    level: 5, dictionary: dictionary) # hard
    end
  end

  trait :english do
    lang 'EN'

    after :create do |dictionary|
      FactoryGirl.create(:noun, noun: 'secret',    level: 1, dictionary: dictionary)  # easy
      FactoryGirl.create(:noun, noun: 'combat',    level: 2, dictionary: dictionary)  # easy
      FactoryGirl.create(:noun, noun: 'emergency', level: 3, dictionary: dictionary)  # easy
      FactoryGirl.create(:noun, noun: 'tomato',    level: 4, dictionary: dictionary)  # easy
      FactoryGirl.create(:noun, noun: 'ellipse',   level: 5, dictionary: dictionary)  # easy
      FactoryGirl.create(:noun, noun: 'terminal',  level: 6, dictionary: dictionary)  # easy
      FactoryGirl.create(:noun, noun: 'value',     level: 7, dictionary: dictionary)  # medium
      FactoryGirl.create(:noun, noun: 'parrot',    level: 8, dictionary: dictionary)  # medium
      FactoryGirl.create(:noun, noun: 'garlic',    level: 9, dictionary: dictionary)  # medium
      FactoryGirl.create(:noun, noun: 'barrel',    level: 10, dictionary: dictionary) # hard
      FactoryGirl.create(:noun, noun: 'trooper',   level: 11, dictionary: dictionary) # hard
      FactoryGirl.create(:noun, noun: 'portal',    level: 12, dictionary: dictionary) # hard
      FactoryGirl.create(:noun, noun: 'scene',     level: 13, dictionary: dictionary) # hard
      FactoryGirl.create(:noun, noun: 'knight',    level: 14, dictionary: dictionary) # hard
      FactoryGirl.create(:noun, noun: 'axe',       level: 15, dictionary: dictionary) # hard
    end
  end
end
