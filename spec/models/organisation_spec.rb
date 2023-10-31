require 'rails_helper'

RSpec.describe Organisation, type: :model do
  subject {build(:organisation)}
  let(:valid_organisation) { build(:organisation, :organisation_model, :valid_organisation) }
  let(:blank_organisation) { build(:organisation, :organisation_model, :blank_organisation) }
  let(:not_vat_registered_org) { build(:organisation, :organisation_model, vat_registered: false, validate_vat_registered: true) }
  let(:invalid_vat_registered_org) { build(:organisation, :organisation_model, vat_registered: nil, validate_vat_registered: true) }
  let(:custom_org_type_blank) { build(:organisation, :organisation_model, custom_org_type: nil, validate_custom_org_type: true) }

  # Set the state of the organisations to ensure any error 
  # messages are there to be seen in the tests. 
  before do
    blank_organisation.valid?
  end

  # create a hash of attributes/fields that should have presence
  # of errors.
  describe "Validation of mandatory fields" do
    fields_with_presence_errors = {
      name: 'Enter the name of your organisation',
      line1: "Enter the first line of your organisation's address",
      townCity: "Enter the town or city where your organisation is located",
      county: "Enter the county where your organisation is located",
      postcode: "Enter the postcode where your organisation is located",
      org_type: "Select the type of organisation that will be running your project"
    }

    # Loop through each field to check they have an error
    # and that the error matches what it should be.
    fields_with_presence_errors.each do |field, message|
      it "is invalid without a #{field}" do
        blank_organisation[field] = nil
        expect(blank_organisation.valid?).to be(false)
        expect(blank_organisation.errors[field]).to include(message)
      end
    end
  end  

  # create a hash of attributes/fields that should have length limits
  # with their error message.
  describe "Validation of length for relevant fields" do
    length_fields = {
      name: [255, "Organisation name must be 255 characters or fewer"],
      company_number: [20, "Company number must be 20 characters or fewer"],
      charity_number: [20, "Charity number must be 20 characters or fewer. For example 1234567 in England and Wales, SC000123 in Scotland, or 10000-0 in Northern Ireland"],
      vat_number: [[9, 12], "Enter the VAT number of your organisation in the correct format"]
    }
    
    # Loop through each field to check they have an error
    # and that the error matches what it should be.
    length_fields.each do |field, details|
      max_length, message = details
    
      it "validates length of #{field} to be within valid constraints" do
        expect(valid_organisation.valid?).to be(true)
    
        if max_length.is_a?(Array)
          # For VAT number, we have a range.
          min_len, max_len = max_length
          too_long = build(:organisation, field => 'A' * (max_len + 1))
          too_short = build(:organisation, field => 'A' * (min_len - 1))

          if field == :vat_number
            too_long.validate_vat_number = true
            too_short.validate_vat_number = true
          end
          
          expect(too_long.valid?).to be(false)
          expect(too_short.valid?).to be(false)
          expect(too_long.errors[field]).to include(message)
          expect(too_short.errors[field]).to include(message)
          
        else
          too_long = build(:organisation, field => 'A' * (max_length + 1))

          if field == :company_number
            too_long.validate_company_number = true
          elsif field == :charity_number
            too_long.validate_charity_number = true
          end         
    
          expect(too_long.valid?).to be(false)
          expect(too_long.errors[field]).to include(message)
        end
      end
    end
  end

  # org_type tests
  describe "validation or org_type" do
    it 'has a valid org type' do 
      expect(valid_organisation.valid?).to be(true)
      expect(blank_organisation.errors[:org_type]).to include("Select the type of organisation that will be running your project")
    end

    it 'validates the presence of org_type when org_type is blank' do
      expect(blank_organisation.valid?).to be(false)
      expect(blank_organisation.errors[:org_type]).to include("Select the type of organisation that will be running your project")
    end
    
    it 'validates the org_type with the correct enum' do
      valid_org_type = build(:organisation, org_type: 3)
      expect(valid_org_type.org_type).to eq("community_interest_company")
    end
    
    it 'should allow organization types within the range 0 to 11' do
      (0..11).each do |org_type|
        valid_org = build(:organisation, org_type: org_type)
        expect(valid_org.valid?).to be(true), "Expected organization type #{org_type} to be valid, but got errors: #{valid_org.errors[:org_type].join(', ')}"
      end
    end
  
    # We are testing an enum, so should recieve an ArgumentError.
    it 'should raise an ArgumentError for invalid organization types' do
        invalid_org_types = [-1, 12, 200, "invalid"]
          invalid_org_types.each do |org_type|
            expect { subject.org_type = org_type }.to raise_error(ArgumentError), "Expected an ArgumentError to be raised for org_type #{org_type.inspect}, but it wasn't."
          end      
    end
  end   

  # testing custom_org_type
  describe "Validation of custom_org_type" do
    it 'passes validation if custom_org_type is present when validate_custom_org_type is true' do
      expect(valid_organisation.valid?).to be(true)
    end

    it 'fails validation if custom_org_type is blank when validate_custom_org_type is true' do
      blank_organisation.validate_custom_org_type = true
      expect(blank_organisation.valid?).to be(false)
      expect(blank_organisation.errors[:custom_org_type]).to include("Specify your organisation type")
    end

    it 'passes validation regardless of custom_org_type value when validate_custom_org_type is false' do
      custom_org_type_blank.validate_custom_org_type = false
      expect(custom_org_type_blank.valid?).to be(true)
    end
  end  

  # tests for board_members_or_trustees
  # Iterate through each set of test data for different attributes.
  # Each set of test data consists of an attribute and an array of test cases.
  describe "More complex validations for attributes" do
    [
      {
        attribute: :board_members_or_trustees,  # The attribute to be tested
        cases: [
          # Array of test cases, each containing a value to test and the expected error message.
          { value: -1, error: "Enter an amount greater than -1" },
          { value: "Twenty One", error: "Number of board members or trustees must be a number" },
          { value: 2147483648, error: "Enter an amount less than 2147483648" },
          { value: nil, error: nil }
        ]
      },
    ].each do |test_data|
      attribute = test_data[:attribute]
      cases = test_data[:cases]

      # Testing when the corresponding validate flag for the attribute is true
      context "when validate_#{attribute} is true" do
        before { subject.send("validate_#{attribute}=", true) }

        # Iterate through each case and apply the test
        cases.each do |test_case|
          it "handles value: #{test_case[:value]}" do
            subject.send("#{attribute}=", test_case[:value])

            # Validate the subject and compare with the expected outcome
            expect(subject.valid?).to eq(test_case[:error].nil?)

            # Check for error messages if any are expected
            if test_case[:error]
              expect(subject.errors[attribute]).to include(test_case[:error])
            else
              expect(subject.errors[attribute]).to be_empty
            end
          end
        end
      end

      describe "Conditional Validation of Attributes" do
        # Testing when the corresponding validate flag for the attribute is false
        context "when validate_#{attribute} is false" do
          before { subject.send("validate_#{attribute}=", false) }

          cases.each do |test_case|
            it "skips validation for value: #{test_case[:value]}" do
              subject.send("#{attribute}=", test_case[:value])
              expect(subject.valid?).to be(true)
              expect(subject.errors[attribute]).to be_empty
            end
          end
        end
      end  
    end  

  end  

  # Tests inclusion of vat_registered
  describe "VAT Registered Validations" do
    it 'fails validation if vat_registered is neither true or false when validate_vat_registered is true' do
      expect(invalid_vat_registered_org.valid?).to be(false)
      expect(invalid_vat_registered_org.errors[:vat_registered]).to include("Select an option to tell us whether your organisation is VAT registered")
    end

    it 'passes validation if vat_registered is true when validate_vat_registered is true' do
      expect(valid_organisation.valid?).to be(true)
    end

    it 'passes validation if vat_registered is false when validate_vat_registered is true' do
      expect(not_vat_registered_org.valid?).to be(true)
    end

    it 'passes validation regardless of vat_registered value when validate_vat_registered is false' do
      invalid_vat_registered_org.validate_vat_registered = false
      expect(invalid_vat_registered_org.valid?).to be(true)
    end
  end  

  # Tests that the validate_xyz? methods work
  describe "Conditionally validating fields" do
    fields_to_validate = [
      :name,
      :org_type,
      :custom_org_type,
      :address,
      :board_members_or_trustees,
      :vat_registered,
      :vat_number,
      :company_number,
      :charity_number,
    ]
  
    fields_to_validate.each do |field|
      it "should validate #{field} when validate_#{field} is set to true" do
        subject.public_send("validate_#{field}=", true)
        expect(subject.public_send("validate_#{field}?")).to eq(true)
      end
    end
  end

  # Tests for Organisation associations
  # We could use the 'shoulda' gem which tests associations
  describe 'Associations' do

    it 'can exist without pre_applications' do
      expect(valid_organisation.pre_applications).to be_empty
    end

    it 'can have many pre_applications' do
      pre_application1 = create(:pre_application, organisation: valid_organisation)
      pre_application2 = create(:pre_application, organisation: valid_organisation)
      
      expect(valid_organisation.pre_applications).to include(pre_application1, pre_application2)
    end

    it 'can exist without a funding_applications' do
      expect(valid_organisation.funding_applications).to be_empty
    end

    it 'can have many funding_applications' do
      funding_application1 = create(:funding_application, organisation: valid_organisation)
      funding_application2 = create(:funding_application, organisation: valid_organisation)
      
      expect(valid_organisation.funding_applications).to include(funding_application1, funding_application2)
    end

    it 'can exist without organisations_org_types' do
      expect(valid_organisation.organisations_org_types).to be_empty
    end
     
    it 'can have many organisations_org_types' do
      organisation = Organisation.create!()
      
      org_type_1 = OrgType.create!(id: SecureRandom.uuid, created_at: DateTime.now, updated_at: DateTime.now) 
      org_type_2 = OrgType.create!(id: SecureRandom.uuid, created_at: DateTime.now, updated_at: DateTime.now) 
      
      organisations_org_type_1 = OrganisationsOrgType.create!(id: SecureRandom.uuid, organisation: organisation, org_type: org_type_1, created_at: DateTime.now, updated_at: DateTime.now)
      organisations_org_type_2 = OrganisationsOrgType.create!(id: SecureRandom.uuid, organisation: organisation, org_type: org_type_2, created_at: DateTime.now, updated_at: DateTime.now)
      
      expect(organisation.organisations_org_types).to include(organisations_org_type_1, organisations_org_type_2)
    end
    
    it 'can have many org_types through organisations_org_types' do
      organisation = Organisation.create!()
      
      org_type1 = OrgType.create!()
      org_type2 = OrgType.create!()
      
      OrganisationsOrgType.create!(organisation: organisation, org_type: org_type1)
      OrganisationsOrgType.create!(organisation: organisation, org_type: org_type2)
      
      expect(organisation.org_types).to include(org_type1, org_type2)
    end
  
    it 'can exist without org_types through organisations_org_types' do
      expect(valid_organisation.org_types).to be_empty
    end
  
    it 'can exist without users_organisations' do
      expect(valid_organisation.users_organisations).to be_empty
    end
  
    it 'can have many users_organisations' do
      user1 = create(:user)
      user2 = create(:user)
    
      user_org1 = create(:users_organisation, organisation: valid_organisation, user: user1)
      user_org2 = create(:users_organisation, organisation: valid_organisation, user: user2)
    
      expect(valid_organisation.users_organisations).to include(user_org1, user_org2)
    end
    
  
    it 'can exist without users through users_organisations' do
      expect(valid_organisation.users).to be_empty
    end
  
    it 'can have many users through users_organisations' do
      user1 = create(:user)
      user2 = create(:user)
  
      create(:users_organisation, organisation: valid_organisation, user: user1)
      create(:users_organisation, organisation: valid_organisation, user: user2)
  
      expect(valid_organisation.users).to include(user1, user2)
    end
  end

end
