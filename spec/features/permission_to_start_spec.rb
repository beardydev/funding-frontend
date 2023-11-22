require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.feature 'SfxPtsPayment', type: :feature do

  # Happy path test.
  # Does not test file upload functionality. Example in 
  # enter_and_save_capital_work function below
  # Could be expanded to check validation and error messages
  scenario 'Successful submission of a permission to start for a large ' \
    'delivery application' do

    begin

      setup_data_and_login()

      mock_large_application_retrieval()

      mock_agreement_in_place()

      mock_all_delivery_pts_salesforce_api_client_responses()

      allow_any_instance_of(NotifyMailer).to \
        receive (:pts_submission_confirmation) # and do nothing

      # Dashboard
      visit '/'
      expect(page).to have_text I18n.t("dashboard.awarded_projects.sub_heading")
      expect(page).to have_text('Mock Large Delivery test')

      # Delivery start page
      click_link_or_button 'Mock Large Delivery test'
      expect(page).to have_text 'Delivery Phase'
      expect(page).to have_text '21/09/2021'
      expect(page).to have_text 'Delivery Org Name'
      expect(page).to have_text 'NL-21-00001'
      expect(page).to have_text 'Delivery Project Title'
      click_link_or_button 'Start now'

      # Delivery approved purposes
      expect(page).to have_text 'Approved Purpose 1'
      choose 'Yes, the Approved Purposes match'
      click_link_or_button I18n.t('buttons.labels.default')

      # Delivery project costs
      expect(page).to have_text 'Cost heading one'
      expect(page).to have_text '1,234.00'
      expect(page).to have_text '987.00'
      expect(page).to have_text '2,221.00'
      expect(page).to have_text 'del pay percentage'
      expect(page).to have_text '33.00'

      choose 'Yes, the projects costs are correct'
      click_link_or_button I18n.t('buttons.labels.default')

      # Delivery agreed costs documents
      expect(page).to have_text 'Upload a cost breakdown and cashflow, with ' \
       'an indication of when you will be seeking grant payments'

      choose 'I have emailed a cost breakdown and cashflow to my Investment ' \
        'Manager'
      click_link_or_button I18n.t('buttons.labels.default')

      # Delivery are cash contriubutions correct
      expect(page).to have_text 'Are the cash contributions still correct?'
      expect(page).to have_text '22.00'
      expect(page).to have_text 'cc description'

      choose 'Yes, the cash contributions are correct'
      click_link_or_button I18n.t('buttons.labels.default')

      # Delivery evidence of secured cash contributions
      expect(page).to have_text 'Evidence of secured cash contributions'
      choose 'No, I do not have evidence for secured cash contributions yet'
      click_link_or_button I18n.t('buttons.labels.default')

      # Delivery evidence of fundraising plan
      expect(page).to have_text 'Evidence of fundraising plan'
      choose 'I have emailed a fundraising plan to my Investment Manager'
      click_link_or_button I18n.t('buttons.labels.default')

      # Delivery Are the non-cash contributions still correct?
      expect(page).to have_text 'Are the non-cash contributions still correct?'
      choose 'Yes, the non-cash contributions are correct'
      click_link_or_button I18n.t('buttons.labels.default')

      # Delivery timetable ot work programme
      expect(page).to have_text 'Upload a proposed timetable or work ' \
        'programme with milestones including dates for getting grant ' \
          'payments and giving project updates'
      choose 'I have emailed a proposed timetable or work programme ' \
        'to my Investment Manager'
      click_link_or_button I18n.t('buttons.labels.default')

      # Delivery project management structure
      expect(page).to have_text 'Upload a project management structure, ' \
        'including methods for choosing consultants, contracts and suppliers'
      choose 'I have emailed a project management structure to my ' \
        'Investment Manager'
      click_link_or_button I18n.t('buttons.labels.default')

      # Delivery property ownership evidence
      expect(page).to have_text 'Evidence of who owns any property that ' \
        'forms part of the project and information on restrictions or ' \
          'other claims on it'
      choose 'I have emailed evidence of ownership to my Investment Manager'
      click_link_or_button I18n.t('buttons.labels.default')

      # Delivery permissions or licences - go in and create some
      expect(page).to have_text 'Have you received any new statutory ' \
        'permissions or licences?'
      choose 'Yes, I have received new statutory permissions or licences'
      click_link_or_button I18n.t('buttons.labels.default')

      # Delivery Add a statutory permission or licence - no errors
      expect(page).to have_text 'Add a statutory permission or licence'
      fill_in('statutory_permission_or_licence_licence_type', with: 'perm 1')
      fill_in('statutory_permission_or_licence_date_day', with: '01')
      fill_in('statutory_permission_or_licence_date_month', with: '02')
      fill_in('statutory_permission_or_licence_date_year', with: '2003')
      click_link_or_button 'Add a statutory permission or licence'

      # Delivery Add statutory permission or licence evidence
      expect(page).to have_text 'Do you want to upload evidence for ' \
        'this statutory permission or licence?'
      choose 'No, I do not have evidence yet'
      click_link_or_button I18n.t('buttons.labels.default')

      # Delivery statutory permission or licence summary - make a change
      expect(page).to have_text 'You have added 1 statutory permission or ' \
        'licence'
      expect(page).to have_text 'perm 1'
      click_link_or_button 'Change'

      # Delivery statutory permission or licence summary - make a change
      expect(page).to have_text 'Add a statutory permission or licence'
      fill_in('statutory_permission_or_licence_licence_type', 
          with: 'amended permission')
      click_link_or_button 'Add a statutory permission or licence'

      # consider evidence for the changed permission or licence
      expect(page).to have_text 'Do you want to upload evidence for ' \
      'this statutory permission or licence?'
      choose 'No, I do not have evidence yet'
      click_link_or_button I18n.t('buttons.labels.default')

      # Delivery statutory permission or licence summary
      # Check the changed text then remove it
      expect(page).to have_text 'amended permission'
      expect(page).not_to have_text 'perm 1'
      expect(page).to have_text 'You have added 1 statutory permission or ' \
      'licence'
      click_link_or_button 'Remove'
      expect(page).not_to have_text 'amended permission'
      expect(page).to have_text 'You have added 0 statutory permission or ' \
      'licences'

      # Finally - add a permission or licence for checking later
      choose 'Yes, I want to add another statutory permission or licence'
      click_link_or_button I18n.t('buttons.labels.default')
      fill_in('statutory_permission_or_licence_licence_type', 
          with: 'a permission')
      fill_in('statutory_permission_or_licence_date_day', with: '02')
      fill_in('statutory_permission_or_licence_date_month', with: '03')
      fill_in('statutory_permission_or_licence_date_year', with: '2004')
      click_link_or_button 'Add a statutory permission or licence'
      choose 'No, I do not have evidence yet'
      click_link_or_button I18n.t('buttons.labels.default')
      choose 'No, I do not want to add another statutory permission or licence'
      click_link_or_button I18n.t('buttons.labels.default')
      
      # Signatories
      expect(page).to have_text 'Details of 2 signatories authorised to ' \
        'sign on behalf of your organisation'
      fill_in('sfx_pts_payment_legal_sig_one', with: 'first signatory name')
      fill_in('sfx_pts_payment_legal_sig_two', with: 'second signatory name')
      click_link_or_button I18n.t('buttons.labels.default')

      # Partnerships
      expect(page).to have_text 'Are you applying on behalf of a partnership?'
      choose 'Yes, I am applying on behalf of a partnership'
      fill_in('sfx_pts_payment_project_partner_name', with: 'partner name')
      click_link_or_button I18n.t('buttons.labels.default')

      # Declaration
      expect(page).to have_text 'By completing this Declaration,'
      check 'I agree with the above statements.'
      expect(page).to \
        have_field('sfx_pts_payment_agrees_to_declaration', checked: true)
      click_link_or_button I18n.t('buttons.labels.default')
      
      # Capybara not posting to the update method here.  Not determined why.
      # Instead, visit the next page by visiting link directly.
      # Download instructions
      visit '/salesforce-experience-application/' \
        "#{@sfx_application.salesforce_case_id}/download-instructions"
      expect(page).to \
        have_text 'Before you submit the Permission to Start Form'
      click_link_or_button I18n.t('buttons.labels.continue')

      # print form
      expect(page).to have_text 'Download and sign Permission to Start form'
      expect(page).to have_text 'Project title: Delivery Project Title'
      expect(page).to have_text 'Project reference number: NL-21-00001'
      expect(page).to have_text 'Grant expiry date: 21/09/2021'
      expect(page).to have_text 'Organisation: Delivery Org Name'
      expect(page).to have_text 'Approved Purpose 1'
      expect(page).to have_text 'Cost heading one'
      expect(page).to have_text '1,234.00' # Costs__c
      expect(page).to have_text '987.00' # Vat__c
      expect(page).to have_text '2,221.00' # Cost + Vat
      expect(page).to have_text 'Total VAT allocation: £33.00'
      expect(page).to have_text 'Total contingency allocation: £0.00'
      expect(page).to have_text 'Payment percentage: del pay percentage %'
      expect(page).to have_text 'Document emailed to Investment Manager'
      expect(page).to have_text 'cc description' # cash contribution
      expect(page).to have_text '22.00' # cash contribution amount
      expect(page).to have_text I18n.t('salesforce_experience_application.' \
        'cash_contribution_evidence.bullets.i_provided_evidence')
      expect(page).to have_text I18n.t('salesforce_experience_' \
        'application.fundraising_evidence.bullets.i_have_emailed')
      expect(page).to have_text I18n.t('salesforce_experience_application.' \
        'property_ownership_evidence.bullets.i_have_emailed')
      
      # These three check are for:
      # * Cost breakdown and cashflow
      # * Timetable or programme
      # * Project management and procurement
      expect(page).to \
        have_text("payments\nDocument emailed to Investment Manager")
      expect(page).to \
        have_text("updates\nDocument emailed to Investment Manager")
      expect(page).to \
        have_text("suppliers\nDocument emailed to Investment Manager")

      # check page for statutory permissions or licences data
      expect(page).to have_text("first permission\nNo")  
      click_link_or_button I18n.t('buttons.labels.continue')

      # upload-permission-to-start
      expect(page).to have_text("Upload signed Permission to Start Form")
      upload_pts_form()
      click_link_or_button "Delete" # Test delete then upload again.
      upload_pts_form()
      click_link_or_button I18n.t('buttons.labels.submit')

      # confirmation/submitted page
      expect(page).to have_text("Permission to Start submitted")

    ensure

      Flipper[:permission_to_start_enabled].disable

    end

  end

  # The journey for large delivery and development applications is the
  # same.  However, content on these pages differ, so check these:
  # * Start page
  # * Project costs pages
  # * Print-form page
  #
  # The cash contributions pages will also show different information
  # for dev and delivery phase grants - but this is filtered in the
  # SOQL query - which is mocked at this test level.
  scenario 'Large development application specific pages show correct ' \
    'content' do

    begin

      setup_data_and_login()

      # change application type to development
      @sfx_application.application_type = 1
      @sfx_application.save

      mock_large_application_retrieval()

      mock_agreement_in_place()

      mock_all_development_pts_salesforce_api_client_responses()

      # Dashboard
      visit '/'
      expect(page).to have_text I18n.t(
        "dashboard.awarded_projects.sub_heading"
      )
      expect(page).to have_text('Mock Large Development test')
      click_link_or_button 'Mock Large Development test'

      # Development start page - specific to dev phase
      expect(page).to have_text 'Development Phase'
      expect(page).to have_text '22/10/2021'
      expect(page).to have_text 'Development Org Name'
      expect(page).to have_text 'NL-21-00001'
      expect(page).to have_text 'Development Project Title'
      click_link_or_button 'Start now'

      # Development approved purposes - not specific to dev phase
      expect(page).to have_text 'Approved Purpose 1'
      choose 'Yes, the Approved Purposes match'
      click_link_or_button I18n.t('buttons.labels.default')

      # Development project costs - specific to dev phase
      expect(page).to have_text 'Cost heading one'
      expect(page).to have_text '1,234.00'
      expect(page).to have_text '987.00'
      expect(page).to have_text '2,221.00'
      expect(page).to have_text 'dev pay percentage'
      expect(page).to have_text '44.00'
      choose 'Yes, the projects costs are correct'
      click_link_or_button I18n.t('buttons.labels.default')

      # Print-form page
      visit '/salesforce-experience-application/' \
      "#{@sfx_application.salesforce_case_id}/print-form"
      expect(page).to have_text 'Download and sign Permission to Start form'
      expect(page).to have_text '22/10/2021'
      expect(page).to have_text 'Development Org Name'
      expect(page).to have_text 'Development Project Title'
      expect(page).to have_text 'Total VAT allocation: £44.00'
      expect(page).to have_text 'Total contingency allocation: £0.00'
      expect(page).to have_text 'Payment percentage: dev pay percentage %'
      click_link_or_button I18n.t('buttons.labels.continue')

    end
  
  end

  private

  # Setup data and login to service:
  #
  # Turn on flipper for PTS
  # Create user
  # login
  def setup_data_and_login()
    
    Flipper[:permission_to_start_enabled].enable

    user = create(:user)

    #setup users organisation details
    user.organisations.first.update(
      name: 'Test Organisation',
      line1: '10 Downing Street',
      line2: 'Westminster',
      townCity: 'London',
      county: 'London',
      postcode: 'SW1A 2AA',
      org_type: 1
    )

    @sfx_application = create(:sfx_pts_payment)

    login_as(user, scope: :user)

  end

  # Retreives large dev and delivery application information in the same format
  # that dashboard_helper would.
  # This does not test that the Salesforce code or filters on record type work.
  def mock_large_application_retrieval()

    delivery = [
      {:status => I18n.t('generic.not_started'), 
        :salesforce_info => {
          :Project_Title__c => 'Mock Large Delivery test',
          :Id => '5003G000006MH75QAG'
        }
      }
    ]

    development = [
      {:status => I18n.t('generic.not_started'), 
        :salesforce_info => {
          :Project_Title__c => 'Mock Large Development test',
          :Id => '5003G000006MH75QAG'
        }
      }
    ]
    
    large_applications = {delivery: delivery, development: development}

    allow_any_instance_of(DashboardHelper).to receive(:get_large_salesforce_applications).and_return(large_applications)

  end

  def mock_agreement_in_place
    allow_any_instance_of(DashboardHelper).to receive(:legal_agreement_in_place?).and_return(false)
  end

  # This IS NOT what Salesforce will return for any particular call.
  # This response that satisfies ALL the required responses for the
  # pts_salesforce_api_client.
  #
  # PermissionToStartHelper is a module, so its functions aren't 
  # limited to an instance. Hence response caters to all.
  #
  # Response always has one row.  Multiple rows to be covered in unit 
  # testing.
  def mock_all_delivery_pts_salesforce_api_client_responses()

    # Todo - take out the dev stuff and create a new resp for
    # a new del test
    mock_salesforce_response = [
      {
        :Grant_Expiry_Date__c => '2021-09-21',         
        :Project_Reference_Number__c => 'NL-21-00001',
        :Project_Title__c => 'Delivery Project Title',
        :Approved_Purposes__c => 'Approved Purpose 1',
        :Delivery_payment_percentage__c => 'del pay percentage',
        :Total_delivery_costs_VAT__c => '33.00',
        :Cost_heading__c => 'Cost heading one',
        :Costs__c => '1234.00',
        :Vat__c => '987.00',
        :Amount_you_have_received__c => '22.00',
        :Description_for_cash_contributions__c => 'cc description',
        :Source_Of_Funding__c => 'source of funding',
        :RecordType => {
          :DeveloperName => 'Large'
        },
        :Account => {
          :Name => 'Delivery Org Name'
        },
        :attributes => {
          :url => 'a url'
        }
      }
    ]


    salesforce_api_client = PtsSalesforceApi::PtsSalesforceApiClient.new()

    allow(salesforce_api_client).to receive(:run_salesforce_query).and_return(mock_salesforce_response)

    allow(salesforce_api_client).to receive(:create_pts_form_record).and_return('a063G000000Bp9KQAS')

    allow_any_instance_of(PermissionToStartHelper).to receive(:get_pts_salesforce_api_instance).and_return(salesforce_api_client)    

    # The check below could be used to check expected SOQL runs
    # expect(salesforce_api_client).to receive(:run_salesforce_query).with('', '', '')
    
  end

  # This IS NOT what Salesforce will return for any particular call.
  # This response that satisfies ALL the required responses for the
  # pts_salesforce_api_client.
  #
  # PermissionToStartHelper is a module, so its functions aren't 
  # limited to an instance. Hence response caters to all.
  #
  # Response always has one row.  Multiple rows to be covered in unit 
  # testing.
  def mock_all_development_pts_salesforce_api_client_responses()

    mock_salesforce_response = [
      {
        :Development_grant_expiry_date__c => '2021-10-22',         
        :Project_Reference_Number__c => 'NL-21-00001',
        :Project_Title__c => 'Development Project Title',
        :Approved_Purposes__c => 'Approved Purpose 1',
        :Development_payment_percentage__c => 'dev pay percentage',
        :Total_development_costs_VAT__c => '44.00',
        :Cost_heading__c => 'Cost heading one',
        :Costs__c => '1234.00',
        :Vat__c => '987.00',
        :Amount_you_have_received__c => '22.00',
        :Description_for_cash_contributions__c => 'cc description',
        :Source_Of_Funding__c => 'source of funding',
        :RecordType => {
          :DeveloperName => 'Large_Development_250_500k'
        },
        :Account => {
          :Name => 'Development Org Name'
        },
        :attributes => {
          :url => 'a url'
        }
      }
    ]

    salesforce_api_client = PtsSalesforceApi::PtsSalesforceApiClient.new()

    allow(salesforce_api_client).to receive(:run_salesforce_query).and_return(mock_salesforce_response)

    allow_any_instance_of(PermissionToStartHelper).to receive(:get_pts_salesforce_api_instance).and_return(salesforce_api_client)    
    
  end

  def upload_pts_form()
    attach_file(
      "sfx_pts_payment_pts_form_files",
      Rails.root + "spec/fixtures/files/example.txt"
    )
    click_link_or_button "Upload files"
    expect(page).to have_text "Uploaded files\nexample.txt"
  end

end
