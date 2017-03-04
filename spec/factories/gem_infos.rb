FactoryGirl.define do
  factory :gem_info do
    sequence(:name) {|i| "TestGem##{i}" }
  end
end
