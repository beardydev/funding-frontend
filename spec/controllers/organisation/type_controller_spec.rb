require "rails_helper"

RSpec.describe Organisation::TypeController do
  login_user

  describe "GET #show" do

    it "should render the page successfully for a valid organisation" do
      get :show,
          params: { organisation_id: subject.current_user.organisations.first.id }
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
      expect(assigns(:organisation).errors.empty?).to eq(true)
    end

    it "should redirect to root for an invalid organisation" do
      get :show, params: { organisation_id: "invalid" }
      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(:root)
    end

  end

  describe "PUT #update" do

    it "should re-render the page if no params are passed" do

      expect(subject).to \
        receive(:log_errors).with(subject.current_user.organisations.first)

      put :update,
          params: { organisation_id: subject.current_user.organisations.first.id }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)

      expect(assigns(:organisation).errors.empty?).to eq(false)
      expect(
          assigns(:organisation).errors.messages[:org_type][0]
      ).to eq("Select the type of organisation that will be running your " \
              "project")

    end

    it "should re-render the page if an empty org_type param is passed" do

      expect(subject).to \
        receive(:log_errors).with(subject.current_user.organisations.first)

      put :update, params: {
          organisation_id: subject.current_user.organisations.first.id,
          organisation: {
              org_type: ""
          }
      }

      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)

      expect(assigns(:organisation).errors.empty?).to eq(false)
      expect(
          assigns(:organisation).errors.messages[:org_type][0]
      ).to eq("Select the type of organisation that will be running your " \
              "project")

    end

    it "should raise an ArgumentError if an invalid org_type param is passed" do

      expect {
        put :update, params: {
            organisation_id: subject.current_user.organisations.first.id,
            organisation: {
                org_type: "invalid"
            }
        }
      }.to raise_error(ArgumentError, "'invalid' is not a valid org_type")

    end

    it "should successfully update if a valid param is passed" do

      put :update, params: {
          organisation_id: subject.current_user.organisations.first.id,
          organisation: {
              org_type: "local_authority"
          }
      }

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(organisation_org_description_path)
      expect(assigns(:organisation).errors.empty?).to eq(true)
      expect(assigns(:organisation).org_type).to eq("local_authority")

    end

  end

end
