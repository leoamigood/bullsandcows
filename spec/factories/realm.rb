FactoryGirl.define do
  factory :realm, :class => Realm::Base

  trait :telegram do
    initialize_with do
      new(channel, user_id, :telegram)
    end
  end

  trait :web do
    initialize_with do
      new(channel, user_id, :web)
    end
  end
end
