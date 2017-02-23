FactoryGirl.define do
  factory :gem_version do
    gem_info { create :gem_info }
    sequence :version {|i| "#{i}.#{i+1}.#{i+2}" }
  end
end
