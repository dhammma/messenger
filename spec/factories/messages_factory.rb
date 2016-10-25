FactoryGirl.define do
  factory :message do
    sequence :text do |n|
      "Message #{n}"
    end
    created_at { Time.now - rand(100) }
  end
end