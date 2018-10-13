# frozen_string_literal: true

FactoryBot.define do
  factory :gem_version do
    gem_info { create :gem_info }
    sequence(:version) {|i| "#{i}.#{i + 1}.#{i + 2}" }

    trait :vulnerable do
      after(:create) do |version, _evaluator|
        create :vulnerability, gem_version: version
      end
    end
  end
end
