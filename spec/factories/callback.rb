FactoryGirl.define do
  factory :callback, :class => Telegram::Bot::Types::CallbackQuery do
    sequence (:id) { generate_random_int }
  end
end
