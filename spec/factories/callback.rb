FactoryGirl.define do
  factory :callback, :class => Telegram::Bot::Types::CallbackQuery do
    sequence :id do
      Random.rand(2 ** (0.size * 4) / 2 - 1)
    end
  end
end
