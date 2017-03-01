FactoryGirl.define do
  factory :gem_usage do
    gem_version { create :gem_version }
    in_gemfile false

    before(:save) do |r|
      binding.pry
    end

    factory :gem_usage_in_gemfile do
      in_gemfile = true
    end
  end
end
