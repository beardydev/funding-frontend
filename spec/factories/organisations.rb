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
    salesforce_account_id { "sf-123456789" }
    custom_org_type { "CustomType" }
    board_members_or_trustees { 5 }
    vat_registered { true }
    vat_number { "GB123456789" }
    organisation_description { "Sample Description" }
    communities_that_org_serve { ["Community A", "Community B"] }
    leadership_self_identify { ["Leader A", "Leader B"] }
    number_of_employees { 10 }
    number_of_volunteers { 20 }
    volunteer_work_description { "Test Volunteer Work" }
   end

      # A trait to allow testing of blank attributes 
    #that must be present. 
    trait :blank_organisation do
      after(:build) do |org|
      org.validate_name = true
      org.validate_address = true
      org.validate_org_type = true
      org.validate_organisation_description = true
      org.validate_communities_that_org_serve = true
      org.validate_leadership_self_identify = true
      org.validate_board_members_or_trustees = true
      org.validate_charity_number = true
      org.validate_company_number = true
      org.validate_number_of_employees = true
      org.validate_number_of_volunteers = true
      org.validate_vat_registered = true
      org.has_charity_number = "yes"
      org.has_company_number = "yes"
      org.has_number_of_employees = "yes"
      org.has_number_of_volunteers = "yes"
      end

      org_type { nil }
      organisation_description { nil }
      custom_org_type { nil }
      name { nil }
      line1 { nil }
      townCity { nil }
      county { nil }
      postcode { nil }
      communities_that_org_serve { nil }
      company_number { nil }
      charity_number { nil }
      number_of_employees { nil }
      number_of_volunteers { nil }
      vat_registered { nil }
    end
    

    trait :valid_organisation do
      name { 'A' * 255 }
      organisation_description { 'A' * 255 }
    end

    trait :invalid_organisation do
      name { 'A' * 256 }
    end

  end
  