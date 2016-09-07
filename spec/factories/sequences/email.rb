FactoryGirl.define do
  sequence(:email, 'a') { |n| "person.#{n}@example.com" }
end