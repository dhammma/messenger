FactoryGirl.define do
  factory :chat do
    sequence :title do |n|
      "Chat #{n}"
    end

    factory :chat_with_admin do
      after(:create) do |chat|
        chat.add_member create(:user), 'admin'
      end
    end

    factory :chat_with_member do
      transient do
        member_roles []
      end

      after(:create) do |chat, evaluator|
        if evaluator.member_roles.blank?
          chat.members << create(:user)
        else
          chat.add_member create(:user), evaluator.member_roles
        end
      end
    end

    factory :chat_with_members do
      transient do
        members [{ roles: ChatMember::ROLES }]
      end

      after(:create) do |chat, evaluator|
        unless evaluator.members.blank?
          evaluator.members.each do |member|
            member[:roles] ||= []
            chat.add_member create(:user), member[:roles]
          end
        end

        (2 + rand(5)).times do
          user = chat.members.sample
          chat.messages << create(:message, user: user, chat: chat) if user
        end
      end
    end
  end
end
