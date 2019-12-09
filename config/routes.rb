Rails.application.routes.draw do

  namespace :account do
    get 'create-new-account' => 'account#new'
  end

  namespace :organisation do
    get 'summary' => 'summary#summary'
    get 'signatory' => 'legal_signatory#legal_signatory'
    get 'mission' => 'organisation_mission#organisation_mission'
    get 'about' => 'organisation_about#organisation_about'
  end

  namespace :project do
    get 'is-there-any-cash-contributions' => 'project_cash_contribution#project_cash_contribution'
    get 'cash-contributions' => 'project_cash_contribution#project_cash_contribution_yes'
    get 'other-outcomes' => 'project_other_outcomes#project_other_outcomes'
    get 'involvement' => 'project_involvement#project_involvement'
    get 'how-is-your-organisation-best-placed' => 'project_best_placed#project_best_placed'
    get 'how-is-your-project-available' => 'project_availability#project_availability'
    get 'community' => 'project_community#project_community'
    get 'differences' => 'project_differences#project_differences'
    get 'do-you-need-permission' => 'project_permission#project_permission'
    get 'description' => 'project_description#project_description'
    get 'is-the-project-at-your-location' => 'project_location#project_location'
    get 'location' => 'project_location#project_location_no'
    get 'key-dates' => 'project_dates#project_dates'
    get 'about-your-project' => 'about#about'
    get 'new-project' => 'new_project/new_project'
  end

  namespace :grant do
    get 'application' => 'grant_application#grant_application'
    get 'declaration' => 'grant_declaration#grant_declaration'
    get 'summary' => 'grant_summary#grant_summary'
    get 'support-evidence' => 'grant_support_evidence#grant_support_evidence'
    get 'volunteers' => 'grant_volunteers#grant_volunteers'
    get 'non-cash-contributors' => 'grant_non_cash_contributors#grant_non_cash_contributors'
    get 'request' => 'grant_request#grant_request'
  end

  devise_for :users
  resources :projects, except: [:destroy]
  get 'dashboard/show'
  root to: "home#show"
  get 'dashboard' => 'dashboard#show'
  get 'postcode' => 'postcode#show'
  post 'postcode_lookup' => 'postcode#lookup'
  post 'postcode_save' => 'postcode#save'
  get 'logout' => 'logout#logout'
  get 'organisation/organisation_type/organisation_type'
  post 'consumer' => 'released_form#receive' do
    header "Content-Type", "application/json"
  end
  resources :organisation do
    get 'show'
  end
end
