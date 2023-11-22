require 'rails_helper'

RSpec.describe PreApplication::ExpressionOfInterest::StartController, type: :controller do
  login_user

  describe 'PUT #update' do
    context 'when user has a complete organisation' do
      let!(:organisation) { create(:organisation, :complete_details) } 

      before do
        subject.current_user.organisations << organisation
        allow_any_instance_of(OrganisationHelper).to receive(:complete_organisation_details?).and_return(true)
      end

      it 'creates a pre_application and redirects to the expression of interest previous contact path' do
        put :update

        expect(assigns(:pre_application)).not_to be_nil
        expect(assigns(:pre_application).pa_expression_of_interest).not_to be_nil
        expect(response).to redirect_to(
          pre_application_expression_of_interest_previous_contact_path(assigns(:pre_application).id)
        )
      end
    end

    context 'when user has an incomplete organisation' do
      before do
        organisation = create(:organisation, :blank_organisation, :without_validations)
        subject.current_user.organisations << organisation
        allow_any_instance_of(OrganisationHelper).to receive(:complete_organisation_details?).and_return(false)
        put :update
      end

      it 'redirects to the organisation name path' do
        expected_organisation = subject.current_user.organisations.first
        expected_redirect_path = organisation_organisation_name_path(expected_organisation.id)
        expect(response).to redirect_to(expected_redirect_path)
      end
    end

    it 'should redirect to the pa_expression_of_interest path for a complete ' do
      'organisation'

      subject.current_user.organisations.first.update(
        name: 'Test Organisation',
        line1: '10 Downing Street',
        line2: 'Westminster',
        townCity: 'London',
        county: 'London',
        postcode: 'SW1A 2AA',
        org_type: 1
      )

      put :update

      # Expect that a PreApplication and an associated PaExpressionOfInterest
      # have been created
      expect(assigns(:pre_application)).not_to(be_nil)
      expect(assigns(:pre_application).pa_expression_of_interest).not_to(be_nil)
      expect(assigns(:pre_application).user).not_to(be_nil)

      expect(response).to have_http_status(:redirect)

      expect(response).to(
        redirect_to(
          pre_application_expression_of_interest_previous_contact_path(
            pre_application_id: assigns(:pre_application).id
          )
        )
      )

    end

    it 'should redirect to the pa_expression_of_interest path for a complete ' do
      'organisation'

      subject.current_user.organisations.first.update(
        name: 'Test Organisation',
        line1: '10 Downing Street',
        line2: 'Westminster',
        townCity: 'London',
        county: 'London',
        postcode: 'SW1A 2AA',
        org_type: 1
      )

      put :update

      # Expect that a PreApplication and an associated PaExpressionOfInterest
      # have been created
      expect(assigns(:pre_application)).not_to(be_nil)
      expect(assigns(:pre_application).pa_expression_of_interest).not_to(be_nil)
      expect(assigns(:pre_application).user).not_to(be_nil)

      expect(response).to have_http_status(:redirect)

      expect(response).to(
        redirect_to(
          pre_application_expression_of_interest_previous_contact_path(
            pre_application_id: assigns(:pre_application).id
          )
        )
      )

    end

  end

end
