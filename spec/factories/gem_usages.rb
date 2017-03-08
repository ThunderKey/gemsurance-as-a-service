FactoryGirl.define do
  factory :gem_usage do
    gem_version { create :gem_version }
    resource { create :resource }
    in_gemfile false

    factory :gem_usage_in_gemfile do
      in_gemfile = true
    end
  end
end
