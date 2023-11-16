require 'rails_helper'

# TODO - alter / rewrite test to ensure covered.

RSpec.feature 'Organisation', type: :feature do

  # scenario 'Non-selection of an organisation type should return an error' do

  #   begin

  #     Flipper[:new_applications_enabled].enable
  #     Flipper[:import_existing_account_enabled].enable

  #     user = FactoryBot.create(
  #       :user,
  #       name: 'Jane Doe',
  #       date_of_birth: Date.new,
  #       line1: 'line 1',
  #       phone_number: '123',
  #       postcode: 'W11AA',
  #       townCity: 'London',
  #       county: 'London'
  #     )

  #     login_as(user, :scope => :user)

  #     # setup scenario

  #     visit '/'
  #     expect(page).to have_text(
  #       I18n.t('dashboard.funding_applications.buttons.start')
  #     )

  #     click_link_or_button I18n.t('dashboard.funding_applications.buttons.start')

  #     expect(page.title).to include(I18n.t('postcode.page_title'))

  #     expect(page).to have_text I18n.t('postcode.find_your_organisation_address')

  #     click_link_or_button I18n.t('postcode.find_address')

  #     # # Mock retrieve_matching_sf_orgs to return an empty collection of orgs
  #     allow_any_instance_of(AddressController).to receive(:retrieve_matching_sf_orgs).and_return([])
  #     set_address(title_field = 'test')

  #     # test assertion
  #     click_link_or_button 'Save and continue'

  #     expect(page).to have_text(
  #       "#{I18n.t('generic.error')}: #{I18n.t('activerecord.errors.models.organisation.attributes.org_type.blank')}"
  #     )

  #   ensure

  #     Flipper[:new_applications_enabled].disable
  #     Flipper[:import_existing_account_enabled].disable

  #   end

  # end

  scenario 'New Applications Enabled Flipper turned off should not show Start a new project button' do

    user = FactoryBot.create(
      :user,
      name: 'Jane Doe',
      date_of_birth: Date.new,
      line1: 'line 1',
      phone_number: '123',
      postcode: 'W11AA',
      townCity: 'London',
      county: 'London'
    )

    login_as(user, :scope => :user)

    visit '/'

    expect(page).not_to have_text(
      I18n.t('dashboard.funding_applications.buttons.start')
    )

  end

end
