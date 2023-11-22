require 'rails_helper'

# Happy path test.
# Does not test file upload functionality. Example in 
RSpec.feature 'LegalAgreements', type: :feature do
 
  scenario 'Successful completion ' do
    begin

      salesforce_stub
      setup_data_and_login()
      mock_awarded()

      visit '/'

      expect(page).to have_text 'Your funding applications'
      expect(page).to have_text @funding_application.project.project_title

    end
  end

  private

  # Setup data and login to service:
  #
  # Create user
  # login
  def setup_data_and_login()
    
    Flipper[:grant_programme_sff_small].enable
    Flipper[:new_applications_enabled].enable

    user = create(:user)

    # Creates project in factory.
    @funding_application = create(
      :funding_application,
      submitted_on: DateTime.now())

    # Amend project title and save to test database.  
    @funding_application.project.project_title = 'agreement test project'
    @funding_application.project.save!

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

    # Set up relationships between org and funding
    @funding_application.organisation = user.organisations.first
    @funding_application.save!

    # The relationship below is implicit, provided you save as above.
    # user.organisations.first.funding_applications.append(@funding_application)

    login_as(user, scope: :user)

  end

  def mock_awarded
    allow_any_instance_of(DashboardHelper).to receive(:awarded).and_return(true)
  end

end
