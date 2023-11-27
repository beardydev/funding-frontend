require "rails_helper"

RSpec.describe DashboardController do

  describe 'GET #show' do
    login_user

    it 'should render the :show template if all user properties ' \
       'are populated' do

      expect(subject.gon).to receive(:push)

      get :show

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)

      expect(assigns(:projects)).to be_a ActiveRecord::Associations::CollectionProxy
      expect(assigns(:funding_applications)).to be_a ActiveRecord::Associations::CollectionProxy

    end

    it 'should render the :show template but not set the @funding_applications instance variable ' \
       'if the user does not have an organisation set' do

      expect(subject.gon).to receive(:push)

      subject.current_user.organisations.delete_all

      get :show

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)

      expect(assigns(:projects)).to be_a ActiveRecord::Associations::CollectionProxy
      expect(assigns(:funding_applications)).to eq(nil)

    end

    it 'should redirect if not all user properties are populated' do

      subject.current_user.update(name: nil)

      get :show

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(:user_details)

    end

  end

  describe 'GET #orchestrate_dashboard_journey' do
    login_user

    it 'should create an empty organisation and redirect to :organisation_type ' \
    'when the current_user has no organisation when import_existing_account disabled' do

      subject.current_user.organisations.delete_all
      get :orchestrate_dashboard_journey

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(
        organisation_type_path(
          organisation_id: subject.current_user.organisations.first.id
        )
      )

    end

    it 'should not create an empty organisation. It should find the organisation is ' \
       'missing detail(s) and so redirect to :organisation_type when import_existing_account disabled' do

        expect(subject).not_to receive(:create_organisation)
        subject.current_user.organisations.append(
          build(
            :organisation
          )
        )
        get :orchestrate_dashboard_journey

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(
          organisation_type_path(
            organisation_id: subject.current_user.organisations.first.id
          )
        )

    end

    it 'should create an empty organisation and redirect to :postcode_lookup ' \
       'when the current_user has no organisation when import_existing_account enabled' do

      
      begin

        Flipper[:import_existing_account_enabled].enable

        subject.current_user.organisations.delete_all

        get :orchestrate_dashboard_journey

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(
          postcode_path(
            'organisation',
            subject.current_user.organisations.first.id
          )
        )

      ensure
        Flipper[:import_existing_account_enabled].disable
      end


    end

    it 'should not create an empty organisation. It should find the organisation is ' \
       'missing detail(s) and so redirect to :postcode_path when import_existing_account enabled' do

      begin

        Flipper[:import_existing_account_enabled].enable

        expect(subject).not_to receive(:create_organisation)

        subject.current_user.organisations.append(
          build(
            :organisation
          )
        )

        get :orchestrate_dashboard_journey

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(
          postcode_path(
            'organisation',
            subject.current_user.organisations.first.id
          )
        )

      ensure
        Flipper[:import_existing_account_enabled].disable
      end
    end

    it 'should find the organisation is present and redirect to :start_an_application' do
      begin
        Flipper[:grant_programme_sff_small].enable

        subject.current_user.organisations.first.update(
          name: 'Test Organisation',
          line1: '10 Downing Street',
          line2: 'Westminster',
          townCity: 'London',
          county: 'London',
          postcode: 'SW1A 2AA',
          org_type: 1
        )

        expect(subject).not_to receive(:create_organisation)

        get :orchestrate_dashboard_journey

        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(:start_an_application)
      ensure
        Flipper[:grant_programme_sff_small].disable
      end
    end
  end
end
