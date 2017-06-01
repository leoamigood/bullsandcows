FactoryGirl.define do
  factory :message, :class => Telegram::Bot::Types::Message do
    transient do
      realm nil
    end

    factory :callback, :class => Telegram::Bot::Types::CallbackQuery do
      sequence (:id) { generate_random_int }
      transient do
        realm nil
      end
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

      case message.class.name
        when Telegram::Bot::Types::Message.to_s
          message.stub_chain(:chat, :id).and_return(evaluator.realm.channel)

        when Telegram::Bot::Types::CallbackQuery.to_s
          message.stub_chain(:message, :chat, :id).and_return(evaluator.realm.channel)
      end

      message.stub_chain(:from, :language_code).and_return(evaluator.realm.user.language)
      message.stub_chain(:from, :first_name).and_return(evaluator.realm.user.first_name)
      message.stub_chain(:from, :last_name).and_return(evaluator.realm.user.last_name)
      message.stub_chain(:from, :username).and_return(evaluator.realm.user.username)
      message.stub_chain(:from, :id).and_return(evaluator.realm.user.ext_id)
    end
  end
end
