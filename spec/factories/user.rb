FactoryGirl.define do
  factory :user do
    initialize_with do
      new(id, name)
    end
  end
end
