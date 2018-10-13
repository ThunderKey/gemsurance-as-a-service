# frozen_string_literal: true

FactoryBot.define do
  factory :empty_resource, class: Resource do
    sequence(:name) {|n| "Test App #{n}" }
    owner { User.first || create(:user) }

    trait :local do
      resource_type { :local }
      path { File.join Rails.root, 'spec', 'assets', 'valid_app' }
    end

    trait :with_gems do
      after(:create) do |resource|
        3.times { create :gem_usage, resource: resource } if resource.gem_usages.empty?
        resource.reload
      end
    end

    factory :resource, traits: %i(local with_gems)
    factory :resource_without_gems, traits: [:local]
    factory :empty_local_resource, traits: [:local]
  end

  factory :invalid_resource, class: Resource do
    sequence(:name) {|n| "Invalid App #{n}" }
    path { '' }
  end
end
