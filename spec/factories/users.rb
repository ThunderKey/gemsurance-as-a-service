FactoryBot.define do
  factory :user do
    sequence(:email) {|i| "peter.tester.#{i}@example.com" }
    firstname { 'Peter' }
    lastname { 'Tester' }
  end
end
