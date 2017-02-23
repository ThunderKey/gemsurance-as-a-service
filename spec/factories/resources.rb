FactoryGirl.define do
  factory :resource do
    sequence :name {|n| "Test App #{n}" }

    factory :local_resource do
      resource_type :local
      path { File.join Rails.root, 'spec', 'assets', 'valid_app' }
    end
  end

  factory :invalid_resource, class: Resource do
    sequence :name {|n| "Invalid App #{n}" }
    path ''
  end
end
