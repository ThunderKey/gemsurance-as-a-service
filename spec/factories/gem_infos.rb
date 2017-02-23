FactoryGirl.define do
  factory :gem_info do
    sequence(:name) {|i| "TestGem##{i + 1}" }
    source 'https://rubygems.org/'
  end
end
