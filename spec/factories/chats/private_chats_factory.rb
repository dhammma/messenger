FactoryGirl.define do
  factory :private_chat do
    sequence :title do |n|
      "Private chat #{n}"
    end

    factory :private_chat_with_members do
      before(:create) do |chat|
        chat.add_member create(:user)
        chat.add_member create(:user)
      end
    end

    factory :self_chat do
      before(:create) do |chat|
        user = create(:user)
        chat.add_member user
        chat.add_member user.clone
      end
    end
  end

end
