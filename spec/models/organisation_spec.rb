require 'rails_helper'

RSpec.describe Organisation, type: :model do
  subject {build(:organisation)}
  let(:organisation) { create(:organisation) }
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
      name: "Please enter your organisation's name",
      line1: "Enter the first line of your organisation's address",
      townCity: "Enter the town or city where your organisation is located",
      county: "Enter the county where your organisation is located",
      postcode: "Enter the postcode where your organisation is located",
      org_type: "Select which option best describes your organisation's type", 
      communities_that_org_serve: "Select the community that your organisation is dedicated to serving",
      leadership_self_identify: "Select the community that more that 75% of your organisation's leadership and staff self-identify as",
      company_number: "Select if your organisation has a company number",
      charity_number: "Select if your organisation has a charity number",
      vat_registered: "Select if your organisation is VAT registered",
      number_of_employees: "Enter your how many staff your organisation employs",
      number_of_volunteers: "Enter your how many volunteers your organisation has"
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
        end
      end
    end
  end

  describe "Validation of length for company_number" do
    let(:max_length) { 20 }
    let(:error_message) { "Company number must be 20 characters or fewer" }
  
    it "validates length of company_number to be within valid constraints" do
      too_long = build(:organisation, company_number: 'A' * (max_length + 1), has_company_number: 'yes')
  
      # Trigger the validation for company_number
      too_long.validate_company_number = true
  
      expect(too_long.valid?(:company_number_update)).to be(false)
      expect(too_long.errors[:company_number]).to include(error_message)
    end
  end

  
  describe "Validation of length for charity_number" do
    let(:max_length) { 20 }
    let(:error_message) { "Charity number must be 20 characters or fewer. For example 1234567 in England and Wales, SC000123 in Scotland, or 10000-0 in Northern Ireland" }
  
    it "validates length of charity_number to be within valid constraints" do
      too_long = build(:organisation, charity_number: 'A' * (max_length + 1), has_charity_number: 'yes')
  
      # Trigger the validation for charity_number
      too_long.validate_charity_number = true
  
      expect(too_long.valid?(:charity_number_update)).to be(false)
      expect(too_long.errors[:charity_number]).to include(error_message)
    end
  end
  

  describe 'new organisation strategy attributes' do

    it 'allows organisation_description' do
      organisation.organisation_description = 'Sample Description'
      expect(organisation.organisation_description).to eq('Sample Description')
    end

    it 'allows communities_that_org_serve' do
      organisation.communities_that_org_serve = ['Community A', 'Community B']
      expect(organisation.communities_that_org_serve).to eq(['Community A', 'Community B'])
    end

    it 'allows leadership_self_identify' do
      organisation.leadership_self_identify = ['Leader A', 'Leader B']
      expect(organisation.leadership_self_identify).to eq(['Leader A', 'Leader B'])
    end

    it 'allows number_of_employees' do
      organisation.number_of_employees = 10
      expect(organisation.number_of_employees).to eq(10)
    end

    it 'allows number_of_volunteers' do
      organisation.number_of_volunteers = 20
      expect(organisation.number_of_volunteers).to eq(20)
    end

    it 'allows volunteer_work_description' do
      organisation.volunteer_work_description = 'Test Volunteer Work'
      expect(organisation.volunteer_work_description).to eq('Test Volunteer Work')
    end
  end

  # org_type tests
  describe "validation or org_type" do
    it 'has a valid org type' do 
      expect(valid_organisation.valid?).to be(true)
      expect(blank_organisation.errors[:org_type]).to include("Select which option best describes your organisation's type")
    end

    it 'validates the presence of org_type when org_type is blank' do
      expect(blank_organisation.valid?).to be(false)
      expect(blank_organisation.errors[:org_type]).to include("Select which option best describes your organisation's type")
    end
    
    it 'validates the org_type with the correct enum' do
      valid_org_type = build(:organisation, org_type: 3)
      expect(valid_org_type.org_type).to eq("community_interest_company")
    end
    
    it 'should allow organization types within the range 0 to 17' do
      (0..17).each do |org_type|
        valid_org = build(:organisation, org_type: org_type)
        valid_org.custom_org_type = 'Some Custom Type' if org_type == 9
        expect(valid_org.valid?).to be(true), "Expected organization type #{org_type} to be valid, but got errors: #{valid_org.errors.full_messages.join(', ')}"
      end
    end
    

    it 'should allow organization type 9 (other) to be valid' do
      org_type = 9
      valid_org = Organisation.new(org_type: org_type, custom_org_type: 'Some Custom Type')
      expect(valid_org.valid?).to be(true), "Expected organization type #{org_type} to be valid, but got errors: #{valid_org.errors.full_messages.join(', ')}"
    end

  
    # We are testing an enum, so should recieve an ArgumentError.
    it 'should raise an ArgumentError for invalid organization types' do
        invalid_org_types = [-1, 18, 200, "invalid"]
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

    # For the custom_org_type test
    it 'fails validation if custom_org_type is blank when validate_custom_org_type is true' do
      blank_organisation = Organisation.new(org_type: 9)
      blank_organisation.validate_custom_org_type = true
      expect(blank_organisation.valid?).to be(false)
      expect(blank_organisation.errors[:custom_org_type]).to include("Enter your organisation's type")
    end

    it 'passes validation regardless of custom_org_type value when validate_custom_org_type is false' do
      custom_org_type_blank.validate_custom_org_type = false
      expect(custom_org_type_blank.valid?).to be(true)
    end
  end  

  # tests for board_members_or_trustees,organisation_description
  # and volunteer_work_description
  # Iterate through each set of test data for different attributes.
  # Each set of test data consists of an attribute and an array of test cases.
  describe "More complex validations for attributes" do
    [
      {
        attribute: :board_members_or_trustees,
        cases: [
          { value: -1, error: "Enter an amount greater than -1" },
          { value: "Twenty One", error: "Number of board members or trustees must be a number" },
          { value: 2147483648, error: "Enter an amount less than 2147483648" },
        ]
      },
      {
        attribute: :organisation_description,
        cases: [
          { value: nil, error: "Enter the work your organisation does" },
          { value: "Some work", error: nil },
          { value: "Some work" * 500, error: "Description of your organisation and the work your organisation does must be 500 words or fewer" }
        ]
      },
      {
        attribute: :volunteer_work_description,
        cases: [ 
          { value: nil, error: "Enter the work your volunteers do" },
          { value: "Some work", error: nil },
          { value: "Some work" * 500, error: "The work your volunteers do must be 500 words or fewer" }

        ]
      },
    ].each do |test_data|
      attribute = test_data[:attribute]
      cases = test_data[:cases]
  
      context "when validate_#{attribute} is true and #{attribute}_required? is true" do
        before do
          allow(subject).to receive(:validate_board_members_or_trustees?).and_return(true)
          allow(subject).to receive(:board_members_or_trustees_required?).and_return(true)
          allow(subject).to receive(:validate_organisation_description?).and_return(true)
          allow(subject).to receive(:validate_volunteer_work_description?).and_return(true)
          subject.valid? 
        end
  
        cases.each do |test_case|
          it "validates #{attribute} with value: #{test_case[:value]}" do
            subject.send("#{attribute}=", test_case[:value])
            subject.valid?  
  
            
            if test_case[:error].nil?
              expect(subject.errors[attribute]).to be_empty, -> { "expected no errors for #{attribute} but got: #{subject.errors[attribute].join(', ')}" }
            else
              expect(subject.errors[attribute]).to include(test_case[:error]), -> { "expected error '#{test_case[:error]}' for #{attribute}, but got: #{subject.errors[attribute].join(', ')}" }
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
      expect(invalid_vat_registered_org.errors[:vat_registered]).to include("Select if your organisation is VAT registered")
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
      :organisation_description,
      :communities_that_org_serve,
      :leadership_self_identify,
      :number_of_employees,
      :number_of_volunteers,
      :volunteer_work_description,
      :governing_documents,
      :governing_document_file    
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

    # Test the governing document associations
      let(:valid_organisation) { create(:organisation) }
      let(:dummy_file) do
        Rack::Test::UploadedFile.new(
          Rails.root.join('spec', 'fixtures', 'files', 'test_document.pdf'),
          'application/pdf'
        )
      end

      it 'can exist without governing_document_files' do
        expect(valid_organisation.governing_document_file).to be_empty
      end

      it 'can have many governing_document_files' do
        valid_organisation.governing_document_file.attach(dummy_file)
        valid_organisation.governing_document_file.attach(dummy_file)

        expect(valid_organisation.governing_document_file.count).to eq(2)
        expect(valid_organisation.governing_document_file.first).to be_an_instance_of(ActiveStorage::Attachment)
        expect(valid_organisation.governing_document_file.first.blob).to be_an_instance_of(ActiveStorage::Blob)
      end
    end

end
