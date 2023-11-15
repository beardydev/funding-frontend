Rails.application.routes.draw do

  # Lambdas are used in this file where we conditionally want to redirect routes
  # based on Flipper configuration settings. The use of lambdas is so that the 
  # corresponding Flipper.enabled check happens dynamically when the route is 
  # accessed, rather than when the routes are first initialised at runtime.

  # Devise root scope - used to determine the authenticated
  # and unauthenticated root pages
  devise_scope :user do
    unauthenticated do
      root to: "user/sessions#new"
    end
    authenticated :user do
      root to: "dashboard#show", as: :authenticated_root
    end
  end

  constraints lambda { !Flipper.enabled?(:registration_enabled) } do
    devise_scope :user do
      get "/users/sign_up",  :to => "devise/sessions#new"
    end
  end

  # Override the Devise registration controller, which allows us
  # to create an organisation when a user is created
  devise_for :users,
             :controllers  => {
                 registrations: 'user/registrations',
                 sessions: 'user/sessions'
             }

  # Account section of the service
  namespace :account do
    get 'create-new-account', to: 'account#new'
    get 'account-created', to: 'account#account_created'
  end

  # User section of the service
  namespace :user do
    get 'details', to: 'details#show'
    put 'details', to: 'details#update'
    # 
    get 'existing-details-error', to: 'existing_details_error#show', constraints: lambda { Flipper.enabled?(:import_existing_contact_enabled) }
  end

  # Dashboard section of the service
  get '/orchestrate-dashboard-journey', to: 'dashboard#orchestrate_dashboard_journey', constraints: lambda { Flipper.enabled?(:new_applications_enabled) }
  get '/orchestrate-dashboard-journey', to: redirect('/', status: 302), constraints: lambda { !Flipper.enabled?(:new_applications_enabled) }

  # Start an Application section of the service
  get 'start-an-application', to: 'new_application#show', constraints: lambda { Flipper.enabled?(:new_applications_enabled) }
  get 'start-an-application', to: redirect('/', status: 302), constraints: lambda { !Flipper.enabled?(:new_applications_enabled) }

  put 'start-an-application', to: 'new_application#update', constraints: lambda { Flipper.enabled?(:new_applications_enabled) }
  put 'start-an-application', to: redirect('/', status: 302), constraints: lambda { !Flipper.enabled?(:new_applications_enabled) }

  get 'problem-with-project', to: 'problem_with_project#show'

  # Modular address section of the service
  # Used in /user, /organisation and /3-10k/project
  scope '/:type/:id/address' do
    get '/postcode', to: 'address#postcode_lookup'
    post '/address-results',
         to: 'address#display_address_search_results'
    put '/address-details',
        to: 'address#assign_address_attributes'
    get '/address',
        to: 'address#show'
    put '/address',
        to: 'address#update'
    # This route ensures that attempting to navigate back to the list of
    # address results redirects the user back to the search page
    get '/address-results',
        to: 'address#postcode_lookup'
    # This route ensures that users can navigate back to the address details
    # page
    get '/address-details',
        to: 'address#show'
  end

  # Organisation section of the service
  namespace :organisation do
    scope '/:organisation_id' do
      get '/organisation-name', to: 'organisation_name#show'
      put '/organisation-name', to: 'organisation_name#update'
      get '/type', to: 'type#show'
      put '/type', to: 'type#update'
      get '/org-description', to: 'org_description#show'
      put '/org-description', to: 'org_description#update'
      get '/communities-that-org-serve', to: 'communities_that_org_serve#show'
      put '/communities-that-org-serve', to: 'communities_that_org_serve#update' 
      get '/leadership-self-identify', to: 'leadership_self_identify#show'
      put '/leadership-self-identify', to: 'leadership_self_identify#update'
      get '/charity-number', to: 'charity_number#show'
      put '/charity-number', to: 'charity_number#update'
      get '/company-number', to: 'company_number#show'
      put '/company-number', to: 'company_number#update'
      get '/vat-registered', to: 'vat_registered#show'
      put '/vat-registered', to: 'vat_registered#update'
      get '/board-members-or-trustees', to: 'board_members_or_trustees#show'
      put '/board-members-or-trustees', to: 'board_members_or_trustees#update'
      get '/number-of-employees', to: 'number_of_employees#show'
      put '/number-of-employees', to: 'number_of_employees#update'
      get '/number-of-volunteers', to: 'number_of_volunteers#show'
      put '/number-of-volunteers', to: 'number_of_volunteers#update'
      get '/volunteer-work-description', to: 'volunteer_work_description#show'
      put '/volunteer-work-description', to: 'volunteer_work_description#update'
      get '/governing-documents', to: 'governing_documents#show'
      put '/governing-documents', to: 'governing_documents#update'
      get '/governing-documents-question', to: 'governing_documents#question_show'
      put '/governing-documents-question', to: 'governing_documents#question_update'      
      get '/summary', to: 'summary#show'
      put '/summary', to: 'summary#update'
      get '/existing-organisations-error', to: 'existing_organisations_error#show', constraints: lambda { Flipper.enabled?(:import_existing_account_enabled) }
    end

  end

  # Pre-application section of the service
  scope '/pre-application', module: 'pre_application', as: :pre_application do

      # where  scope '/:pre_application_id' do was

      # scope '/organisation', module: 'org', as: :organisation do

      #   scope '/:organisation_id' do
     
    scope 'project-enquiry', module: 'project_enquiry', as: :project_enquiry do

      post 'start', to: 'start#update'

      scope '/:pre_application_id' do

        get 'previous-contact', to: 'previous_contact_name#show'
        put 'previous-contact', to: 'previous_contact_name#update'
        get 'what-is-the-need-for-this-project', to: 'project_reasons#show'
        put 'what-is-the-need-for-this-project', to: 'project_reasons#update'
        get 'what-will-the-project-do', to: 'what_project_does#show'
        put 'what-will-the-project-do', to: 'what_project_does#update'
        get 'do-you-have-a-working-title', to: 'working_title#show'
        put 'do-you-have-a-working-title', to: 'working_title#update'
        get 'heritage-focus', to: 'heritage_focus#show'
        put 'heritage-focus', to: 'heritage_focus#update'
        get 'programme-outcomes', to: 'programme_outcomes#show'
        put 'programme-outcomes', to: 'programme_outcomes#update'
        get 'who-will-be-involved', to: 'project_participants#show'
        put 'who-will-be-involved', to: 'project_participants#update'
        get 'timescales', to: 'project_timescales#show'
        put 'timescales', to: 'project_timescales#update'
        get 'likely-cost', to: 'project_likely_cost#show'
        put 'likely-cost', to: 'project_likely_cost#update'
        get 'likely-ask', to: 'potential_funding_amount#show'
        put 'likely-ask', to: 'potential_funding_amount#update'
        get 'check-your-answers', to: 'check_answers#show'
        put 'check-your-answers', to: 'check_answers#update'
        get 'submitted', to: 'submitted#show'
        put 'submitted', to: 'submitted#update'
        get 'summary', to: 'summary#show'

      end

    end

    scope 'expression-of-interest', module: 'expression_of_interest', as: :expression_of_interest do

      post 'start', to: 'start#update'

      scope '/:pre_application_id' do
        
        get 'previous-contact', to: 'previous_contact_name#show'
        put 'previous-contact', to: 'previous_contact_name#update'
        get 'what-will-the-project-do', to: 'what_project_does#show'
        put 'what-will-the-project-do', to: 'what_project_does#update'
        get 'do-you-have-a-working-title', to: 'working_title#show'
        put 'do-you-have-a-working-title', to: 'working_title#update'
        get 'investment-principles', to: 'investment_principles#show'
        put 'investment-principles', to: 'investment_principles#update'
        get 'heritage-focus', to: 'heritage_focus#show'
        put 'heritage-focus', to: 'heritage_focus#update'
        get 'what-is-the-need-for-this-project', to: 'project_reasons#show'
        put 'what-is-the-need-for-this-project', to: 'project_reasons#update'
        get 'timescales', to: 'project_timescales#show'
        put 'timescales', to: 'project_timescales#update'
        get 'overall-cost', to: 'overall_cost#show'
        put 'overall-cost', to: 'overall_cost#update'
        get 'likely-ask', to: 'potential_funding_amount#show'
        put 'likely-ask', to: 'potential_funding_amount#update'
        get 'likely-submission-description', to: 'likely_submission_description#show'
        put 'likely-submission-description', to: 'likely_submission_description#update'
        get 'check-your-answers', to: 'check_answers#show'
        put 'check-your-answers', to: 'check_answers#update'
        get 'submitted', to: 'submitted#show'
        put 'submitted', to: 'submitted#update'
        get 'summary', to: 'summary#show'

      end

    end

  end

  # Application section of the service
  scope '/application', module: 'funding_application', as: :funding_application do

    scope '/:application_id' do

      get 'tasks', to: 'tasks#show'

      # This section relates to the applicant journey of
      # accepting a grant, including if the applicant is
      # also a legal signatory
      scope '/agreement', module: 'legal_agreements' do

        get 'how-to-accept', to: 'how_to_accept#show'
        put 'how-to-accept', to: 'how_to_accept#update'
        get 'check-project-details', to: 'check_details#show'
        put 'check-project-details', to: 'check_details#update'
        get 'additional-documents', to: 'additional_docs#show'
        put 'additional-documents', to: 'additional_docs#update'
        get 'project-details-correct', to: 'project_details_correct#show'
        put 'project-details-correct', to: 'project_details_correct#update'
        get 'applicant-is-signatory', to: 'applicant_is_signatory#show'
        put 'applicant-is-signatory', to: 'applicant_is_signatory#update'
        get 'second-signatory', to: 'second_signatory#show'
        put 'second-signatory', to: 'second_signatory#update'
        get 'both-signatories', to: 'both_signatories#show'
        put 'both-signatories', to: 'both_signatories#update'
        get 'awaiting-signatories', to: 'awaiting_signatories#show'
        get 'terms-and-conditions', to: 'terms#show'
        put 'terms-and-conditions', to: 'terms#update'
        get 'agree-to-grant', to: 'agree#show'
        put 'agree-to-grant', to: 'agree#update'
        get 'upload-terms-and-conditions', to: 'upload_terms#show'
        put 'upload-terms-and-conditions', to: 'upload_terms#update'
        put 'submit-uploaded-terms-and-conditions', to: 'upload_terms#upload'
        get 'submitted', to: 'submitted#show'
        get 'view-signed', to: 'view_signed#show'

        # This section relates to the legal signatory-only journey
        # of accepting a grant. We use the 'as' parameter here so that the
        # auto-generated routes differ from the non-applicant agreement
        # section (e.g. funding_application_signatories_terms_and_conditions)
        scope '/:encoded_signatory_id', module: 'signatories', as: 'signatories' do
          
          get 'check-project-details', to: 'check_details#show'
          put 'check-project-details', to: 'check_details#update'
          get 'terms-and-conditions', to: 'terms#show'
          put 'terms-and-conditions', to: 'terms#update'
          get 'agree-to-grant', to: 'agree#show'
          put 'agree-to-grant', to: 'agree#update'
          get 'upload-terms-and-conditions', to: 'upload_terms#show'
          put 'upload-terms-and-conditions', to: 'upload_terms#update'
          put 'submit-uploaded-terms-and-conditions', to: 'upload_terms#upload'
          get 'submitted', to: 'submitted#show'
          
        end

      end

      scope '/payments', module: 'payment_requests', as: 'payment_request' do

        get 'start', to: 'start#show', constraints: lambda { Flipper.enabled?(:payment_requests_enabled) }
        post 'start', to: 'start#update', constraints: lambda { Flipper.enabled?(:payment_requests_enabled) }

        scope '/:payment_request_id' do

          get 'bank-details', to: 'enter_bank_details#show'
          put 'bank-details', to: 'enter_bank_details#update'

          get 'confirm-bank-details', to: 'confirm_bank_details#show'
          put 'confirm-bank-details', to: 'confirm_bank_details#update'
          put 'confirm-bank-details-submitted', to: 'confirm_bank_details#save_and_continue'

          get 'submitted', to: 'submitted#show'
          
        end

      end

      scope 'bank-details', module: 'bank_details', as: 'bank_details' do

        get 'start', to: 'start#show'

        get 'enter', to: 'enter#show'
        post 'enter', to: 'enter#update'

        get 'confirm', to: 'confirm#show'
        post 'confirm', to: 'confirm#update'

        get 'upload-evidence', to: 'upload_evidence#show'
        post 'upload-evidence', to: 'upload_evidence#update'

      end

      scope 'progress-and-spend', module: 'progress_and_spend', as: :progress_and_spend do
        get 'start', to: 'start#show', constraints: lambda { Flipper.enabled?(:progress_and_spend_enabled) }
        post 'start', to: 'start#update', constraints: lambda { Flipper.enabled?(:progress_and_spend_enabled) }

        get 'select_journey', to: 'select_journey#show'
        post 'select_journey', to: 'select_journey#update'

        get 'progress-and-spend-tasks', to: 'tasks#show'
        post 'progress-and-spend-tasks', to: 'tasks#update'

        scope '/:completed_arrears_journey_id' do
          get 'submit-your-answers', to: 'submit#show'
        end      

        scope 'previous-submissions', module: 'previous_submissions', as: :previous_submissions do
          get 'previous-submission-dates', to: 'previous_submission_dates#show'
          post 'previous-submission-dates', to: 'previous_submission_dates#update'

          scope '/:completed_arrears_journey_id' do
            get 'previously-submitted', to: 'previously_submitted#show'
            post 'previously-submitted', to: 'previously_submitted#update'

            scope 'submission-summary', module: 'submission_summary', as: :submission_summary do
              scope '/:progress_update_id' do
                get 'progress-update-submission', to: 'progress_update_submission#show' 
                post 'progress-update-submission', to: 'progress_update_submission#update' 
  
                get 'approved-purposes-submission', to: 'approved_purposes_submission#show'
                post 'approved-purposes-submission', to: 'approved_purposes_submission#update'
              end
              
              scope '/:payment_request_id' do
                get 'payments-submission', to: 'payments_submission#show'
                post 'payments-submission', to: 'payments_submission#update'
              end
              
            end

          end
        end

        scope 'progress-update', module: 'progress_update', as: 'progress_update' do  
          scope '/:progress_update_id' do
            
            get 'photos', to: 'photos#show'
            post 'photos', to: 'photos#update'
            get 'events', to: 'events#show'
            post 'events', to: 'events#update'
            get 'new-staff', to: 'new_staff#show'
            post 'new-staff', to: 'new_staff#update'

            scope 'procurement', module: 'procurement', as: 'procurement' do

              get 'procured-goods', to: 'procured_goods#show'
              post 'procured-goods', to: 'procured_goods#update'

              get 'procurement-report', to: 'procurement_report#show'
              post 'procurement-report', to: 'procurement_report#update'

              get 'add-procurement', to: 'add_procurement#show'
              post 'add-procurement', to: 'add_procurement#update'

              get 'procurements-summary', to: 'procurements_summary#show'
              post 'procurements-summary', to: 'procurements_summary#update'
              delete 'procurements-summary/:procurement_id',
                to: 'procurements_summary#delete',
                as: :procurement_delete

                scope '/:procurement_id' do
                  get 'edit-procurement', to: 'edit_procurement#show'
                  post 'edit-procurement', to: 'edit_procurement#update'
                end

            end

            get 'additional-grant-conditions', to: 'additional_grant_conditions#show'
            post 'additional-grant-conditions', to: 'additional_grant_conditions#update'
            get 'completion-date', to: 'completion_date#show'
            post 'completion-date', to: 'completion_date#update'
            get 'change-completion-date', to: 'new_expiry_date#show'
            post 'change-completion-date', to: 'new_expiry_date#update'
            get 'permissions-or-licences', to: 'statutory_permission_licence#show'
            post 'permissions-or-licences', to: 'statutory_permission_licence#update'

            scope 'risk', module: 'risk', as: 'risk' do
              get 'risk-question', to: 'risk_question#show'
              post 'risk-question', to: 'risk_question#update'
              get 'risk-register', to: 'risk_register#show'
              post 'risk-register', to: 'risk_register#update'
              get 'risk-add', to: 'risk_add#show'
              post 'risk-add', to: 'risk_add#update'
              get 'risk-summary', to: 'risk_summary#show'
              post 'risk-summary', to: 'risk_summary#update'
              delete 'risk-summary/:risk_id',
                to: 'risk_summary#delete',
                as: :risk_delete

                scope '/:risk_id' do
                  get 'risk-edit', to: 'risk_edit#show'
                  post 'risk-edit', to: 'risk_edit#update'
                end

            end

            scope 'cash-contribution', module: 'cash_contribution', as: 'cash_contribution' do

              get 'cash-contribution-question', to: 'cash_contribution_question#show'
              post 'cash-contribution-question', to: 'cash_contribution_question#update'
              get 'cash-contribution-select', to: 'cash_contribution_select#show'
              post 'cash-contribution-select', to: 'cash_contribution_select#update'

              scope '/:cash_contribution_id' do
                get 'cash-contribution-now', to: 'cash_contribution_now#show'
                post 'cash-contribution-now', to: 'cash_contribution_now#update'
                get 'cash-contribution-future', to: 'cash_contribution_future#show'
                post 'cash-contribution-future', to: 'cash_contribution_future#update'
              end

            end

            scope 'volunteer', module: 'volunteer', as: 'volunteer' do

              get 'volunteer-question', to: 'volunteer_question#show'
              post 'volunteer-question', to: 'volunteer_question#update'

              get 'volunteer-add', to: 'volunteer_add#show'
              post 'volunteer-add', to: 'volunteer_add#update'

              get 'volunteer-summary', to: 'volunteer_summary#show'
              post 'volunteer-summary', to: 'volunteer_summary#update'
              delete 'volunteer-summary/:volunteer_id',
                to: 'volunteer_summary#delete',
                as: :volunteer_delete

                scope '/:volunteer_id' do
                  get 'volunteer-edit', to: 'volunteer_edit#show'
                  post 'volunteer-edit', to: 'volunteer_edit#update'
                end

            end

            scope 'non-cash-contribution', module: 'non_cash_contribution', as: 'non_cash_contribution' do

              get 'non-cash-contribution-question', to: 'non_cash_contribution_question#show'
              post 'non-cash-contribution-question', to: 'non_cash_contribution_question#update'
              get 'non-cash-contribution-add', to: 'non_cash_contribution_add#show'
              post 'non-cash-contribution-add', to: 'non_cash_contribution_add#update'
              get 'non-cash-contribution-summary', to: 'non_cash_contribution_summary#show'
              post 'non-cash-contribution-summary', to: 'non_cash_contribution_summary#update'
              delete 'non-cash-contribution-summary/:non_cash_contribution_id',
                to: 'non_cash_contribution_summary#delete',
                as: :non_cash_contribution_delete

              scope '/:non_cash_contribution_id' do
                get 'non-cash-contribution-edit', to: 'non_cash_contribution_edit#show'
                post 'non-cash-contribution-edit', to: 'non_cash_contribution_edit#update'
              end

            end

            get 'check-your-answers', to: 'check_your_answers#show'
            post 'check-your-answers', to: 'check_your_answers#update'

            get 'approved-purposes', to: 'approved_purposes#show'
            post 'approved-purposes', to: 'approved_purposes#update'

            get 'demographic', to: 'demographic#show'
            post 'demographic', to: 'demographic#update'

            get 'outcome', to: 'outcome#show'
            post 'outcome', to: 'outcome#update'

            get 'digital-outputs-question', to: 'digital_outputs_question#show'
            post 'digital-outputs-question', to: 'digital_outputs_question#update'

            get 'digital-outputs-description', to: 'digital_outputs_description#show'
            post 'digital-outputs-description', to: 'digital_outputs_description#update'

            get 'funding-acknowledgement', to: 'funding_acknowledgement#show'
            post 'funding-acknowledgement', to: 'funding_acknowledgement#update'

            get 'check-outcome-answers', to: 'check_outcome_answers#show'
            post 'check-outcome-answers', to: 'check_outcome_answers#update'

          end

        end

        scope 'payments', module: 'payments', as: 'payments' do
          scope '/:payment_request_id' do

            get 'vat-status-changes', to: 'vat_status_changes#show'
            post 'vat-status-changes', to: 'vat_status_changes#update'

            get 'spend-so-far', to: 'spend_so_far#show'
            post 'spend-so-far', to: 'spend_so_far#update'

            get 'what-spend', to: 'what_spend#show'
            post 'what-spend', to: 'what_spend#update'

            get 'low-spend-select', to: 'low_spend_select#show'
            post 'low-spend-select', to: 'low_spend_select#update'
            get 'low-spend-add', to: 'low_spend_add#show'
            post 'low-spend-add', to: 'low_spend_add#update'
            get 'low-spend-summary', to: 'low_spend_summary#show'
            post 'low-spend-summary', to: 'low_spend_summary#update'
            delete 'low-spend-summary/:low_spend_id',
              to: 'low_spend_summary#delete',
              as: :low_spend_summary_delete
            scope '/:low_spend_id' do
              get 'low-spend-edit', to: 'low_spend_edit#show'
              post 'low-spend-edit', to: 'low_spend_edit#update'
            end

            get 'table-of-spend', to: 'table_of_spend#show'
            post 'table-of-spend', to: 'table_of_spend#update'

            get 'high-spend-add', to: 'high_spend_add#show'
            post 'high-spend-add', to: 'high_spend_add#update'
            get 'high-spend-summary', to: 'high_spend_summary#show'
            post 'high-spend-summary', to: 'high_spend_summary#update'
            delete 'high-spend-summary/:high_spend_id',
              to: 'high_spend_summary#delete',
              as: :high_spend_summary_delete
            scope '/:high_spend_id' do
              get 'high-spend-evidence', to: 'high_spend_evidence#show'
              post 'high-spend-evidence', to: 'high_spend_evidence#update'
              get 'high-spend-edit', to: 'high_spend_edit#show'
              post 'high-spend-edit', to: 'high_spend_edit#update'
            end

            get 'have-your-bank-details-changed', to: 'have_bank_details_changed#show'
            post 'have-your-bank-details-changed', to: 'have_bank_details_changed#update'

          end

        end

      end

    end
    
    scope 'gp-open-medium', module: 'gp_open_medium', as: :gp_open_medium do

      get 'start', to: 'start#show'
      post 'start', to: 'start#update'

      scope '/:application_id' do
        
        # where scope 'org', module: 'org' do was

        get 'advice', to: 'received_advice#show'
        put 'advice', to: 'received_advice#update'
        get 'first-fund-application', to: 'first_fund_application#show'
        put 'first-fund-application', to: 'first_fund_application#update'
        get 'title', to: 'title#show'
        put 'title', to: 'title#update'
        get 'dates', to: 'dates#show'
        put 'dates', to: 'dates#update'
        get 'why-now', to: 'why_now#show'
        put 'why-now', to: 'why_now#update'
        get 'location', to: 'location#show'
        put 'location', to: 'location#update'
        get 'description', to: 'description#show'
        put 'description', to: 'description#update'
        get 'capital-works', to: 'capital_works#show'
        put 'capital-works', to: 'capital_works#update'
        get 'ownership', to: 'ownership#show'
        put 'ownership', to: 'ownership#update'
        get 'acquisition', to: 'acquisition#show'
        put 'acquisition', to: 'acquisition#update'
        get 'do-you-need-permission', to: 'permission#show'
        put 'do-you-need-permission', to: 'permission#update'
        get 'project-difference', to: 'difference#show'
        put 'project-difference', to: 'difference#update'
        get 'at-risk', to: 'at_risk#show'
        put 'at-risk', to: 'at_risk#update'
        get 'any-formal-designation', to: 'heritage_designations#show'
        put 'any-formal-designation', to: 'heritage_designations#update'
        get 'visitors', to: 'visitors#show'
        put 'visitors', to: 'visitors#update'
        get 'how-does-your-project-matter', to: 'matter#show'
        put 'how-does-your-project-matter', to: 'matter#update'
        get 'environmental-impacts', to: 'environmental_impacts#show'
        put 'environmental-impacts', to: 'environmental_impacts#update'
        get 'your-project-heritage', to: 'heritage#show'
        put 'your-project-heritage', to: 'heritage#update'
        get 'why-is-your-organisation-best-placed', to: 'best_placed#show'
        put 'why-is-your-organisation-best-placed', to: 'best_placed#update'
        get 'partnership', to: 'partnership#show'
        put 'partnership', to: 'partnership#update'
        get 'how-will-your-project-involve-people', to: 'involvement#show'
        put 'how-will-your-project-involve-people', to: 'involvement#update'
        get 'our-other-outcomes', to: 'outcomes#show'
        put 'our-other-outcomes', to: 'outcomes#update'
        get 'how-will-your-project-be-managed', to: 'managed#show'
        put 'how-will-your-project-be-managed', to: 'managed#update'
        get 'how-will-you-evaluate-your-project', to: 'evaluation_description#show'
        put 'how-will-you-evaluate-your-project', to: 'evaluation_description#update'
        get 'plans-to-acknowledge-grant', to: 'acknowledgement_description#show'
        put 'plans-to-acknowledge-grant', to: 'acknowledgement_description#update'
        get 'jobs-or-apprenticeships', to: 'jobs#show'
        put 'jobs-or-apprenticeships', to: 'jobs#update'
        get 'costs', to: 'costs#show'
        put 'costs', to: 'costs#update'
        delete 'costs/:project_cost_id', to: 'costs#delete', as: :cost_delete
        put 'confirm-costs', to: 'costs#validate_and_redirect'
        get 'are-you-getting-cash-contributions',
          to: 'cash_contributions#question'
        put 'are-you-getting-cash-contributions',
          to: 'cash_contributions#question_update'
        get 'cash-contributions', to: 'cash_contributions#show'
        put 'cash-contributions', to: 'cash_contributions#update'
        delete 'cash-contributions/:cash_contribution_id',
          to: 'cash_contributions#delete',
          as: :cash_contribution_delete
        get 'are-you-getting-non-cash-contributions',
          to: 'non_cash_contributions#question'
        put 'are-you-getting-non-cash-contributions',
          to: 'non_cash_contributions#question_update'
        get 'your-grant-request', to: 'grant_request#show'
        get 'non-cash-contributions', to: 'non_cash_contributions#show'
        put 'non-cash-contributions', to: 'non_cash_contributions#update'
        delete 'non-cash-contributions/:non_cash_contribution_id',
          to: 'non_cash_contributions#delete',
          as: :non_cash_contribution_delete
        get 'volunteers', to: 'volunteers#show'
        put 'volunteers', to: 'volunteers#update'
        delete 'volunteers/:volunteer_id', to: 'volunteers#delete', as: :volunteer_delete
        get 'evidence-of-support', to: 'evidence_of_support#show'
        put 'evidence-of-support', to: 'evidence_of_support#update'
        delete 'evidence-of-support/:supporting_evidence_id',
          to: 'evidence_of_support#delete',
          as: :evidence_of_support_delete
        get 'governing-documents', to: 'governing_documents#show'
        put 'governing-documents', to: 'governing_documents#update'
        get 'accounts', to: 'accounts#show'
        put 'accounts', to: 'accounts#update'
        get 'project-plan', to: 'project_plan#show'
        put 'project-plan', to: 'project_plan#update'
        get 'work-briefs', to: 'work_briefs#show'
        put 'work-briefs', to: 'work_briefs#update'
        get 'project-images', to: 'project_images#show'
        put 'project-images', to: 'project_images#update'
        get 'full-cost-recovery', to: 'cost_recovery#show'
        put 'full-cost-recovery', to: 'cost_recovery#update'
        get 'check-your-answers', to: 'check_answers#show'
        put 'check-your-answers', to: 'check_answers#update'
        get 'confirm-declaration', to: 'declaration#show_confirm_declaration'
        put 'confirm-declaration', to: 'declaration#update_confirm_declaration'
        get 'declaration', to: 'declaration#show_declaration'
        put 'declaration', to: 'declaration#update_declaration', constraints: lambda { Flipper.enabled?(:new_applications_enabled) }
        put 'declaration', to: redirect('/', status: 302), constraints: lambda { !Flipper.enabled?(:new_applications_enabled) }
        get 'application-submitted', to: 'application_submitted#show'
        get 'summary', to: 'summary#show'

      end
    
    end
 
    scope 'gp-project', module: 'gp_project', as: :gp_project do

      get 'start', to: 'start#show', constraints: lambda { Flipper.enabled?(:new_applications_enabled) }
      get 'start', to: redirect('/', status: 302), constraints: lambda { !Flipper.enabled?(:new_applications_enabled) }
      post 'start', to: 'start#update', constraints: lambda { Flipper.enabled?(:new_applications_enabled) }
      post 'start', to: redirect('/', status: 302), constraints: lambda { !Flipper.enabled?(:new_applications_enabled) }

      scope '/:application_id' do

        get 'title', to: 'title#show'
        put 'title', to: 'title#update'
        get 'key-dates', to: 'dates#show'
        put 'key-dates', to: 'dates#update'
        get 'location', to: 'location#show'
        put 'location', to: 'location#update'
        get 'description', to: 'description#show'  
        put 'description', to: 'description#update'  
        get 'capital-works', to: 'capital_works#show'
        put 'capital-works', to: 'capital_works#update'
        get 'do-you-need-permission', to: 'permission#show'
        put 'do-you-need-permission', to: 'permission#update'
        get 'project-difference', to: 'difference#show'
        put 'project-difference', to: 'difference#update'
        get 'how-does-your-project-matter', to: 'matter#show'
        put 'how-does-your-project-matter', to: 'matter#update'
        get 'your-project-heritage', to: 'heritage#show'
        put 'your-project-heritage', to: 'heritage#update'
        get 'why-is-your-organisation-best-placed', to: 'best_placed#show'
        put 'why-is-your-organisation-best-placed', to: 'best_placed#update'
        get 'how-will-your-project-involve-people', to: 'involvement#show'
        put 'how-will-your-project-involve-people', to: 'involvement#update'
        get 'our-other-outcomes', to: 'outcomes#show'
        put 'our-other-outcomes', to: 'outcomes#update'
        get 'costs', to: 'costs#show'
        put 'costs', to: 'costs#update'
        delete 'costs/:project_cost_id', to: 'costs#delete', as: :cost_delete
        put 'confirm-costs', to: 'costs#validate_and_redirect'
        get 'are-you-getting-cash-contributions',
            to: 'cash_contributions#question'
        put 'are-you-getting-cash-contributions',
            to: 'cash_contributions#question_update'
        get 'cash-contributions', to: 'cash_contributions#show'
        put 'cash-contributions', to: 'cash_contributions#update'
        delete 'cash-contributions/:cash_contribution_id',
               to: 'cash_contributions#delete',
               as: :cash_contribution_delete
        get 'your-grant-request', to: 'grant_request#show'
        get 'are-you-getting-non-cash-contributions',
            to: 'non_cash_contributions#question'
        put 'are-you-getting-non-cash-contributions',
            to: 'non_cash_contributions#question_update'
        get 'non-cash-contributions', to: 'non_cash_contributions#show'
        put 'non-cash-contributions', to: 'non_cash_contributions#update'
        delete 'non-cash-contributions/:non_cash_contribution_id',
               to: 'non_cash_contributions#delete',
               as: :non_cash_contribution_delete
        get 'volunteers', to: 'volunteers#show'
        put 'volunteers', to: 'volunteers#update'
        delete 'volunteers/:volunteer_id', to: 'volunteers#delete',
               as: :volunteer_delete
        get 'evidence-of-support', to: 'evidence_of_support#show'
        put 'evidence-of-support', to: 'evidence_of_support#update'
        delete 'evidence-of-support/:supporting_evidence_id',
               to: 'evidence_of_support#delete',
               as: :evidence_of_support_delete
        get 'check-your-answers', to: 'check_answers#show'
        put 'check-your-answers', to: 'check_answers#update'
        get 'governing-documents', to: 'governing_documents#show'
        put 'governing-documents', to: 'governing_documents#update'
        get 'accounts', to: 'accounts#show'
        put 'accounts', to: 'accounts#update'
        get 'confirm-declaration', to: 'declaration#show_confirm_declaration'
        put 'confirm-declaration', to: 'declaration#update_confirm_declaration'
        get 'declaration', to: 'declaration#show_declaration'
        put 'declaration', to: 'declaration#update_declaration', constraints: lambda { Flipper.enabled?(:new_applications_enabled) }
        put 'declaration', to: redirect('/', status: 302), constraints: lambda { !Flipper.enabled?(:new_applications_enabled) }
        get 'application-submitted', to: 'application_submitted#show'
        get 'summary', to: 'summary#show'

      end

    end

  end

  scope 'salesforce-experience-application', module: 'salesforce_experience_application', as: :sfx_pts_payment do

    scope '/:salesforce_case_id' do

      get '/permission-to-start', to: 'pts_start#show'
      post '/permission-to-start', to: 'pts_start#update'
      get '/approved-purposes', to: 'approved_purposes#show'
      post '/approved-purposes', to: 'approved_purposes#update'
      get '/agreed-costs', to: 'agreed_costs#show'
      post '/agreed-costs', to: 'agreed_costs#update'
      get '/agreed-costs-documents', to: 'agreed_costs_documents#show'
      post '/agreed-costs-documents', to: 'agreed_costs_documents#update'
      delete '/agreed-costs-documents/:blob_id', to: 'agreed_costs_documents#delete', as: :agreed_costs_doc_blob_delete
      get '/cash-contributions-correct', to: 'cash_contributions_correct#show'
      post '/cash-contributions-correct', to:
        'cash_contributions_correct#update'
      get '/cash-contributions-evidence', to: 
        'cash_contributions_evidence#show'
      post '/cash-contributions-evidence', to: 
        'cash_contributions_evidence#update'
      delete '/cash-contributions-evidence/:blob_id', to: 
        'cash_contributions_evidence#delete', 
          as: :cash_contributions_evidence_blob_delete
      get '/fundraising-evidence', to: 'fundraising_evidence#show'
      post '/fundraising-evidence', to: 'fundraising_evidence#update'
      delete '/fundraising-evidence/:blob_id', to: 
        'fundraising_evidence#delete', 
          as: :fundraising_evidence_blob_delete
      get '/non-cash-contributions-correct', to: 
        'non_cash_contributions_correct#show'
      post '/non-cash-contributions-correct', to: 
        'non_cash_contributions_correct#update'
      get '/timetable-work-programme', to: 'timetable_work_programme#show'
      post '/timetable-work-programme', to: 'timetable_work_programme#update'
      delete '/timetable-work-programme/:blob_id', to: 
        'timetable_work_programme#delete', 
          as: :timetable_work_programme_blob_delete
      get '/project-management-structure', to: 
        'project_management_structure#show'
      post '/project-management-structure', to:
        'project_management_structure#update'
      delete '/project-management-structure/:blob_id', to: 
        'project_management_structure#delete', 
          as: :project_management_structure_blob_delete
      get '/property-ownership-evidence', to: 
        'property_ownership_evidence#show'
      post '/property-ownership-evidence', to:
        'property_ownership_evidence#update'
      delete '/property-ownership-evidence/:blob_id', to: 
        'property_ownership_evidence#delete', 
          as: :property_ownership_evidence_blob_delete
      get '/permissions-or-licences', to: 'permissions_or_licences#show'
      post '/permissions-or-licences', to: 'permissions_or_licences#update'
      get '/permissions-or-licences-add', to: 'permissions_or_licences_add#show'
      post '/permissions-or-licences-add', to: 'permissions_or_licences_add#update'
      get '/permissions-or-licences-edit', to: 'permissions_or_licences_edit#show'
      post '/permissions-or-licences-edit', to: 'permissions_or_licences_edit#update'
      get '/signatories', to: 'signatories#show'
      post '/signatories', to: 'signatories#update'
      get '/partnerships', to: 'partnerships#show'
      post '/partnerships', to: 'partnerships#update'
      get '/declaration', to: 'declaration#show'
      post '/declaration', to: 'declaration#update'
      get '/confirmation', to: 'confirmation#show'
      post '/confirmation', to: 'confirmation#update'
      get '/download-instructions', to: 'download_instructions#show'
      post '/download-instructions', to: 'download_instructions#update'
      get '/print-form', to: 'print_form#show'
      post '/print-form', to: 'print_form#update'
      get '/upload-permission-to-start', to: 'upload_permission_to_start#show'
      post '/upload-permission-to-start', to: 'upload_permission_to_start#update'
      delete '/upload-permission-to-start/:blob_id', to: 
      'upload_permission_to_start#delete', 
        as: :pts_form_files_blob_delete

      scope '/statutory-permission-or-licence', 
        module: 'statutory_permission_or_licence', 
            as: 'statutory_permission_or_licence' do

        get 'add', to: 'add#show'
        post 'add', to: 'add#update'
        get 'summary', to: 'summary#show'
        post 'summary', to: 'summary#update'
        delete 'summary/:statutory_permission_or_licence_id', to: 
          'summary#delete', as: :summary_delete

        scope '/:statutory_permission_or_licence_id' do

          get 'files', to: 'files#show'
          post 'files', to: 'files#update'
          delete '/files/:blob_id', to: 
          'files#delete', 
            as: :files_blob_delete
          get 'change', to: 'change#show'
          post 'change', to: 'change#update'
        end

      end

    end

  end

  # Static pages within the service
  get '/accessibility-statement', to: 'static_pages#show_accessibility_statement'
  get '/service-unavailable', to: 'static_pages#show_service_unavailable_page'

  # Support section of the service
  get 'support', to: 'support#show'
  post 'support', to: 'support#update'
  scope '/support' do
    # We use a scope here, as there is no related Support object
    get 'report-a-problem', to: 'support#report_a_problem'
    post 'report-a-problem', to: 'support#process_problem'
    get 'question-or-feedback', to: 'support#question_or_feedback'
    post 'question-or-feedback', to: 'support#process_question'
  end

  # Endpoint for released forms webhook
  post 'consumer' => 'released_form#receive' do
    header "Content-Type", "application/json"
  end

  # Health check route for GOV.UK PaaS
  get 'health' => 'health#status'

  namespace :help do
    get 'cookies'
    get 'cookie-details'
  end

  # DelayedJob dashboard
  match "/delayed_job" => DelayedJobWeb, :anchor => false, :via => [:get, :post]

  # Import journey for migrated cases
  scope 'import', module: 'import', as: :import do

    scope '/:salesforce_case_id' do

      get '/is-this-your-project', to: 'is_this_your_project#show', constraints: lambda { Flipper.enabled?(:import_enabled) }
      post '/is-this-your-project', to: 'is_this_your_project#update', constraints: lambda { Flipper.enabled?(:import_enabled) }
    
    end

  end

  scope  'admin-portal', module: 'admin_portal', as: :admin_portal do

    get '/', to: 'landing_page#show'
    post '/', to: 'landing_page#update'

    scope 'user/:user_id' do
      
      get '/user-found', to: 'user_found#show'
      post '/user-found', to: 'user_found#update'

      get '/update-contact-details', to: 'update_contact_details#show'
      post '/update-contact-details', to: 'update_contact_details#update'

      get '/move-all-projects', to: 'update_contact_details#move_all_show'
      post '/move-all-projects', to: 'update_contact_details#move_all_update'


      scope 'organisation/:organisation_id' do

        get '/update-organisation-details', to: 'update_organisation_details#show'
        post '/update-organisation-details', to: 'update_organisation_details#update'

        get '/select-to-move', to: 'application_to_move#show'
        post '/select-to-move', to: 'application_to_move#update'

        scope 'application/:application_id' do

          get '/new-main-contact', to: 'new_main_contact#show'
          post '/new-main-contact', to: 'new_main_contact#update'

          scope '/new-main-contact/:new_main_contact_id' do 
            scope '/new_organisation/:new_org_id' do 
              get '/move_application', to: 'move_app#show'
              post '/move_application', to: 'move_app#update'
              get '/moved', to: 'moved#show'
            end
          end
       
        end

      end
      
    end

    get '/reconnection-report', to: 'reconnection_report#show'

  end

end
