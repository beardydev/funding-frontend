require "rails_helper"

RSpec.describe FundingApplication::GpProject::CheckAnswersController do

  login_user

  let(:funding_application) {
    create(
      :funding_application,
      organisation: subject.current_user.organisations.first
    )
  }

  describe "GET #show" do

    it "should render the page successfully for a valid project" do
      get :show,
          params: { application_id: funding_application.id }
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
      expect(assigns(:funding_application).project.errors.empty?).to eq(true)

    end

    it "should redirect to root for an invalid project" do
      get :show, params: { application_id: "invalid" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(:root)
    end

  end

  describe "PUT #update" do

    it "should re-render the page if mandatory project fields have not been " \
       "populated" do

      put :update,
          params: {
              application_id: funding_application.id
          }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)

      expect(assigns(:funding_application).project.errors.empty?).to eq(false)
      expect(assigns(:funding_application).project.errors.messages[:description][0])
          .to eq(I18n.t("activerecord.errors.models.project.attributes.description.blank"))
      expect(assigns(:funding_application).project.errors.messages[:involvement_description][0])
          .to eq(I18n.t("activerecord.errors.models.project.attributes.involvement_description.blank"))
      expect(assigns(:funding_application).project.errors.messages[:project_costs][0])
          .to eq(I18n.t("activerecord.errors.models.project.attributes.project_costs.blank"))

    end

    it "should redirect if mandatory project attributes are populated, and " \
       "the org_type is 'registered_company'" do

      subject.current_user.organisations.first.update(
          org_type: "registered_company"
      )

      funding_application.project.update(
          description: "Test",
          involvement_description: "Test",
      )

      funding_application.project.project_costs << create(
          :project_cost,
          project_id: funding_application.project.id,
          cost_type: "new_staff",
          description: "Test",
          amount: 5000
      )

      put :update,
          params: {
              application_id: funding_application.id
          }

      expect(response).to have_http_status(:redirect)
      expect(response)
          .to redirect_to(:funding_application_gp_project_accounts)

      expect(assigns(:funding_application).project.errors.empty?).to eq(true)

    end

    it "should redirect if mandatory project attributes are populated, and " \
       "the org_type is 'individual_private_owner_of_heritage'" do

      subject.current_user.organisations.first.update(
          org_type: "individual_private_owner_of_heritage"
      )

      funding_application.project.update(
          description: "Test",
          involvement_description: "Test",
          )

      funding_application.project.project_costs << create(
          :project_cost,
          project_id: funding_application.project.id,
          cost_type: "new_staff",
          description: "Test",
          amount: 5000
      )

      put :update,
          params: {
              application_id: funding_application.id
          }

      expect(response).to have_http_status(:redirect)
      expect(response)
          .to redirect_to(:funding_application_gp_project_accounts)

      expect(assigns(:funding_application).project.errors.empty?).to eq(true)

    end

    it "should redirect if mandatory project attributes are populated, and " \
       "the org_type is not 'registered_company' or " \
       "'individual_private_owner_of_heritage'" do

      subject.current_user.organisations.first.update(
          org_type: "registered_charity"
      )

      funding_application.project.update(
          description: "Test",
          involvement_description: "Test",
          )

      funding_application.project.project_costs << create(
          :project_cost,
          project_id: funding_application.project.id,
          cost_type: "new_staff",
          description: "Test",
          amount: 5000
      )

      put :update,
          params: {
              application_id: funding_application.id
          }

      expect(response).to have_http_status(:redirect)
      expect(response)
          .to redirect_to(:funding_application_gp_project_accounts)

      expect(assigns(:funding_application).project.errors.empty?).to eq(true)

    end

  end

end
