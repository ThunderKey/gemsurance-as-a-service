# frozen_string_literal: true

FactoryBot.define do
  factory :gem_info do
    sequence(:name) {|i| "TestGem##{i}" }
  end
end
