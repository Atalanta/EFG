FactoryGirl.define do
  factory :bulk_lending_limits do
    scheme_or_phase_id 23
    sequence(:lending_limit_name) { |n| "lending limit #{n}" }
    allocation_type_id LendingLimitType::Annual.id
    starts_on 1.month.ago
    ends_on { |lending_limit| lending_limit.starts_on.advance(years: 1) }

    association :created_by, factory: :cfe_admin
    association :modified_by, factory: :cfe_admin
  end
end
