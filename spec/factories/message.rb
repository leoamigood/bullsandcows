FactoryGirl.define do
  factory :message, :class => Telegram::Bot::Types::Message do
    transient do
      realm nil
    end
  end

  trait :private do
    after :build do |message|
      message.stub_chain(:chat, :type).and_return('private')
    end
  end

  trait :group do
    after :build do |message|
      message.stub_chain(:chat, :type).and_return('group')
    end
  end

  trait :with_realm do
    after :build do |message, evaluator|
      message.stub_chain(:chat, :id).and_return(evaluator.realm.channel)
      message.stub_chain(:from).and_return(evaluator.realm.user)
      message.stub_chain(:from, :id).and_return(evaluator.realm.user.ext_id)
    end
  end
end
