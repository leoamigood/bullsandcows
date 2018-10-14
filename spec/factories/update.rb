FactoryGirl.define do
  factory :update, :class => Telegram::Bot::Types::Update do
    transient do
      realm :telegram_realm
    end
  end
end
