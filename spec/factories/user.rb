FactoryGirl.define do
  factory :user do
    sequence :ext_id do
      Random.rand(2 ** (0.size * 4) / 2 - 1)
    end

    factory :telegram_user do
      source :telegram
    end
  end
end
