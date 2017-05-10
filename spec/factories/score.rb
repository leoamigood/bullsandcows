FactoryGirl.define do
  factory :score do
    transient do
      realm nil
    end
  end

  trait :winner_by_realm do
    before :create do |score, evaluator|
      score.channel = evaluator.realm.channel
      score.winner_id = evaluator.realm.user.ext_id
    end
  end
end
