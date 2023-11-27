require 'rails_helper'
include ActionView::Helpers::NumberHelper

RSpec.feature 'Dashboard', type: :feature do

  scenario 'Successful redirection to project title page for small grant applications in progress' do

    begin
      Flipper[:grant_programme_sff_small].enable
      Flipper[:new_applications_enabled].enable

      salesforce_stub

      setup_data_and_login()

      visit '/'

      expect(page).to have_text 'test small closure'

      click_link_or_button 'test small closure'

      expect(page)
      .to have_current_path("/application/gp-project/#{@funding_application.project.funding_application_id}/title?locale=en-GB")

    end
  end

  scenario 'Successful redirection to summary page for small grant applicatons in progress when small grants are closed' do
    begin
      Flipper[:grant_programme_sff_small].disable
      Flipper[:new_applications_enabled].enable

      salesforce_stub

      setup_data_and_login()

      visit '/'

      expect(page).to have_text 'test small closure'
      expect(page).to have_text ('Closed')

      click_link_or_button 'test small closure'

      expect(page).to have_current_path(
        "/application/gp-project/#{@funding_application.project.funding_application_id}/summary?locale=en-GB"
      )

      expect(page).not_to have_text I18n.t('gp_project.summary.sub_heading')
      expect(page).to have_text I18n.t('gp_project.summary.small_grants_closed.message')
      expect(page).to have_text I18n.t('gp_project.summary.small_grants_closed.work_in_progress')
      expect(page).not_to have_text I18n.t('views.summary.button')
    ensure
      Flipper[:grant_programme_sff_small].enable
    end
  end

  private

  def setup_data_and_login()
    
    user = create(:user)

    # Creates project in factory.
    @funding_application = create(
      :funding_application,
      )

    # Amend project title and save to test database.  
    @funding_application.project.project_title = 'test small closure'
    @funding_application.project.save!

    # Set up relationships between org and funding
    @funding_application.organisation = user.organisations.first
    @funding_application.save!

    login_as(user, scope: :user)
   
  end

end
