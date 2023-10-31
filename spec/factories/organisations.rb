FactoryBot.define do

  # This blank :organisation is used throughout the test suite
  # best not to change it without knowing where its used. 
  factory :organisation do
  end

  # Everything below and including this organisation model is 
  # used within the organisation_spec.rb.
  trait :organisation_model do
    id { SecureRandom.uuid }
    created_at { Time.current }
    updated_at { Time.current }
    line1 { "123 Main Street" }
    line2 { "Flat 3" }
    line3 { "Third Floor" }
    townCity { "Plymouth" }
    county { "Devon" }
    postcode { "PL1 3TT" }
    org_type { 0 }
    company_number { "COMP12345" }
    charity_number { "CHAR12345" }
    charity_number_ni { 7890 }
    salesforce_account_id { "sf-123456789" }
    custom_org_type { "CustomType" }
    board_members_or_trustees { 5 }
    vat_registered { true }
    vat_number { "GB123456789" }
   end

      # A trait to allow testing of blank attributes 
    #that must be present. 
    trait :blank_organisation do
      after(:build) do |org|
      org.validate_name = true
      org.validate_address = true
      org.validate_org_type = true
      end

      org_type { nil }
      custom_org_type { nil }
      name { nil }
      line1 { nil }
      townCity { nil }
      county { nil }
      postcode { nil }
    end

    trait :valid_organisation do
      name { 'A' * 255 }
    end

    trait :invalid_organisation do
      name { 'A' * 256 }
    end

  end
  