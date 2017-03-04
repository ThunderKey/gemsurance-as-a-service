FactoryGirl.define do
  factory :empty_resource, class: Resource do
    sequence :name {|n| "Test App #{n}" }

    trait :local do
      resource_type :local
      path { File.join Rails.root, 'spec', 'assets', 'valid_app' }
    end

    trait :with_gems do
      after(:create) do |resource|
        if resource.gem_usages.empty?
          3.times { create :gem_usage, resource: resource }
        end
      end
    end

    factory :resource, traits: [:local, :with_gems]
    factory :resource_without_gems, traits: [:local]
    factory :empty_local_resource, traits: [:local]
  end

  factory :invalid_resource, class: Resource do
    sequence :name {|n| "Invalid App #{n}" }
    path ''
  end
end
