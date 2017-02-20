FactoryGirl.define do
  factory :resource do
    sequence :name {|n| "Test App #{n}" }

    factory :local_resource do
      resource_type :local
      path { "/#{name.underscore.gsub('_', '/')}" }
    end
  end

  factory :invalid_resource, class: Resource do
    sequence :name {|n| "Invalid App #{n}" }
    path ''
  end
end
