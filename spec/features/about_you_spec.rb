require 'rails_helper'

RSpec.feature 'Application', type: :feature do
  scenario 'Signed out user' do
    visit('/')
    expect(page.status_code).to eq(200)
    # TODO remove flipper bau
    expect(page).not_to have_content("sign in")
  end

  scenario 'About you page' do
    user = FactoryBot.create(
        :user,
        name: nil,
        date_of_birth: nil,
        phone_number: nil
    )
    login_as(user, scope: :user)
    visit('/')
    expect(page).to have_content('About you')
    fill_in 'Full name', with: 'Jane Doe'
    fill_in 'Telephone number', with: '123'
    fill_in 'Day', with: '01'
    fill_in 'Month', with: '01'
    fill_in 'Year', with: '1970'
    click_button 'Save and continue'
    expect(page).to have_current_path('/user/address')
  end

end