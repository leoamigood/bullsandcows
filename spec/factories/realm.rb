FactoryGirl.define do
  factory :realm do
    transient do
      sequence(:channel) { generate_random_int }
    end

    factory :telegram_realm, :class => Realm::Telegram do
      initialize_with do
        new(channel, user)
      end
    end

    factory :web_realm, :class => Realm::Web do
      initialize_with do
        new(OpenStruct.new(id: channel))
      end
    end
  end
end

