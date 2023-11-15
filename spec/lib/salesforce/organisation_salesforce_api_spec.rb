require 'rails_helper'


RSpec.describe OrganisationSalesforceApi::OrganisationSalesforceApiClient do

  let(:organisation) { FactoryBot.create(:organisation) }
  let(:salesforce_account_id) { 'some_salesforce_id' }

  it 'should call the initialise_client private method when initialising the object' do

    allow_any_instance_of(OrganisationSalesforceApi::OrganisationSalesforceApiClient).to receive(:initialise_client)

    organisation_salesforce_api_client = OrganisationSalesforceApi::OrganisationSalesforceApiClient.new()

    expect(organisation_salesforce_api_client).to have_received(:initialise_client).with(no_args).once

  end

  it 'should set the @client instance variable equal to the result from Restforce.new' \
  ' as part of initialising the object' do

 allow(Restforce).to receive(:new).with(any_args).and_return('test')

 organisation_salesforce_api_client = OrganisationSalesforceApi::OrganisationSalesforceApiClient.new()

 expect(organisation_salesforce_api_client.instance_variable_get(:@client)).to eq('test')

end

it 'should return a Hash when the Restforce client select query is successful in retrieving org details from salesforce' do

  restforce_response = double(
    Name: 'OrganizationName',
    BillingStreet: '123 Main St',
    BillingCity: 'City',
    BillingState: 'State',
    BillingPostalCode: '12345',
    Company_Number__c: '123456',
    Charity_Number__c: '789012',
    Organisation_Type__c: 'Non-Profit',
    Are_you_VAT_registered_picklist__c: 'Yes',
    VAT_number__c: '123456789',
    Number_Of_Board_members_or_Trustees__c: '5',
    Organisation_s_Main_Purpose_Activities__c: 'description',
    Communities_that_org_serves__c: 'Faith communities',
    leadership_self_identify__c: 'Faith communities',
     NumberOfEmployees: '2',
     Number_of_volunteers__c: '2',
     Volunteer_work_description__c: 'volunteer description'
  )

  allow(Restforce).to receive(:new).with(any_args).and_return(double)

  organisation_salesforce_api_client = OrganisationSalesforceApi::OrganisationSalesforceApiClient.new()
    expected_hash = {
      'Name': 'OrganizationName',
      'BillingStreet': '123 Main St',
      'BillingCity': 'City',
      'BillingState': 'State',
      'BillingPostalCode': '12345',
      'Company_Number__c': '123456',
      'Charity_Number__c': '789012',
      'Organisation_Type__c': 'Non-Profit',
      'Are_you_VAT_registered_picklist__c': 'Yes',
      'VAT_number__c': '123456789',
      'Number_Of_Board_members_or_Trustees__c': '5',
      'Organisation_s_Main_Purpose_Activities__c': 'description',
      'Communities_that_org_serves__c': 'Faith communities',
      'leadership_self_identify__c': 'Faith communities',
       'NumberOfEmployees': '2',
       'Number_of_volunteers__c': '2',
       'Volunteer_work_description__c': 'volunteer description'
    }
    allow(organisation_salesforce_api_client)
    .to receive(:run_salesforce_query).and_return([expected_hash])

  expect(organisation_salesforce_api_client.retrieve_existing_sf_org_details(salesforce_account_id))
    .to eq(expected_hash)

  end 

  it 'updates VAT information for an organization' do
    vat_number = '1234567890'
    new_vat_registered_status = 'Yes'

    organisation_salesforce_api_client = OrganisationSalesforceApi::OrganisationSalesforceApiClient.new()

    expect(organisation_salesforce_api_client.instance_variable_get(:@client)).to receive(:update!).with('Account', Id: salesforce_account_id, VAT_number__c: vat_number, Are_you_VAT_registered_picklist__c: new_vat_registered_status)

    organisation_salesforce_api_client.change_organisation_vat_status(salesforce_account_id, vat_number, new_vat_registered_status)
  end

  it 'should raise an exception if the Restforce client update query raises a MatchesMultipleError exception' do

    vat_number = '1234567890'
    new_vat_registered_status = 'Yes'

    organisation_salesforce_api_client = OrganisationSalesforceApi::OrganisationSalesforceApiClient.new()

    allow(organisation_salesforce_api_client.instance_variable_get(:@client))
      .to receive(:update!).and_raise(Restforce::MatchesMultipleError.new('1', 'test'))

    expect { organisation_salesforce_api_client.change_organisation_vat_status(salesforce_account_id, vat_number, new_vat_registered_status) }
      .to raise_error(an_instance_of(Restforce::MatchesMultipleError).and having_attributes(response: 'test'))

  end

  it 'should raise an exception if the Restforce client update query raises a UnauthorizedError exception' do

    vat_number = '1234567890'
    new_vat_registered_status = 'Yes'

    organisation_salesforce_api_client = OrganisationSalesforceApi::OrganisationSalesforceApiClient.new()

    allow(organisation_salesforce_api_client.instance_variable_get(:@client))
      .to receive(:update!).and_raise(Restforce::UnauthorizedError.new('test'))

    expect { organisation_salesforce_api_client.change_organisation_vat_status(salesforce_account_id, vat_number, new_vat_registered_status) }
      .to raise_error(an_instance_of(Restforce::UnauthorizedError))

  end

  it 'should raise an exception if the Restforce client update query raises a EntityTooLargeError exception' do

    vat_number = '1234567890'
    new_vat_registered_status = 'Yes'

    organisation_salesforce_api_client = OrganisationSalesforceApi::OrganisationSalesforceApiClient.new()

    allow(organisation_salesforce_api_client.instance_variable_get(:@client))
      .to receive(:update!).and_raise(Restforce::EntityTooLargeError.new('1', 'test'))

    expect  { organisation_salesforce_api_client.change_organisation_vat_status(salesforce_account_id, vat_number, new_vat_registered_status) }
      .to raise_error(an_instance_of(Restforce::EntityTooLargeError).and having_attributes(response: 'test'))

  end

  it 'should raise an exception if the Restforce client update query raises a ResponseError exception' do

    vat_number = '1234567890'
    new_vat_registered_status = 'Yes'

    organisation_salesforce_api_client = OrganisationSalesforceApi::OrganisationSalesforceApiClient.new()

    allow(organisation_salesforce_api_client.instance_variable_get(:@client))
      .to receive(:update!).and_raise(Restforce::ResponseError.new('1', 'test'))

    expect{ organisation_salesforce_api_client.change_organisation_vat_status(salesforce_account_id, vat_number, new_vat_registered_status) }
      .to raise_error(an_instance_of(Restforce::ResponseError).and having_attributes(response: 'test'))

  end

  context 'when no matching account is found' do
    it 'creates a new Salesforce account' do

      organisation_salesforce_api_client = OrganisationSalesforceApi::OrganisationSalesforceApiClient.new()

      expect(organisation_salesforce_api_client).to receive(:find_matching_account_for_organisation).with(organisation).and_return(nil)

      expect(organisation_salesforce_api_client).to receive(:upsert_account_by_organisation_id).with(organisation).and_return(salesforce_account_id)

      expect(Rails.logger).to receive(:info).with("Upserted an Account record in Salesforce with reference: #{salesforce_account_id}")
      
      expect(organisation_salesforce_api_client.create_organisation_in_salesforce(organisation)).to eq(salesforce_account_id)
    end
  end

  context 'when a matching account is found' do
    it 'upserts the existing account in Salesforce' do

      organisation_salesforce_api_client = OrganisationSalesforceApi::OrganisationSalesforceApiClient.new()

      expect(organisation_salesforce_api_client).to receive(:find_matching_account_for_organisation).with(organisation).and_return(salesforce_account_id)

      expect(organisation_salesforce_api_client).to receive(:upsert_account_by_salesforce_id).with(organisation, salesforce_account_id)

      expect(Rails.logger).to receive(:info).with("Upserted an Account record in Salesforce with reference: #{salesforce_account_id}")
      organisation_salesforce_api_client.create_organisation_in_salesforce(organisation)

    end
  end
 
end
