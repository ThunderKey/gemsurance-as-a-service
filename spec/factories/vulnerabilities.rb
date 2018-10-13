FactoryBot.define do
  factory :vulnerability do
    description { "Example Vulnerability" }
    cve { nil }
    url { "https://example.com/vulnerability" }
    patched_versions { "> 1.2.3" }
    gem_version { create :gem_version }
  end
end
