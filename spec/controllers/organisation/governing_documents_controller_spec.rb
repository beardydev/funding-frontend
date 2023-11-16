# require "rails_helper"

# TODO - Alter and rewrite this file based on when governing docs are uploaded.

# RSpec.describe Organisation::GoverningDocumentsController do

#   login_user

#   let(:funding_application) {
#     create(
#       :funding_application,
#       organisation: subject.current_user.organisations.first
#     )
#   }

#   describe "GET #show" do

#     it "should render the page successfully for a valid project" do
#       get :show,
#           params: { application_id: funding_application.id }
#       expect(response).to have_http_status(:success)
#       expect(response).to render_template(:show)
#       expect(assigns(:funding_application).project.errors.empty?).to eq(true)
#     end

#     it "should redirect to root for an invalid project" do
#       get :show, params: { application_id: "invalid" }
#       expect(response).to have_http_status(:redirect)
#       expect(response).to redirect_to(:root)
#     end

#   end

#   describe "PUT #update" do

#     it "should re-render the show template if no params are passed" do

#       put :update,
#           params: { application_id: funding_application.id }

#       expect(response).to have_http_status(:success)
#       expect(response).to render_template(:show)

#       expect(assigns(:funding_application).project.errors.empty?).to eq(false)
#       expect(
#           assigns(:funding_application).project.errors.messages[:governing_document_file][0]
#       ).to eq(I18n.t("activerecord.errors.models.project.attributes.governing_document_file.inclusion"))

#     end

#     it "should re-render the show template if an empty project param is " \
#        "passed" do

#       put :update,
#           params: {
#               application_id: funding_application.id,
#               project: { }
#           }

#       expect(response).to have_http_status(:success)
#       expect(response).to render_template(:show)

#       expect(assigns(:funding_application).project.errors.empty?).to eq(false)
#       expect(
#           assigns(:funding_application).project.errors.messages[:governing_document_file][0]
#       ).to eq(I18n.t("activerecord.errors.models.project.attributes.governing_document_file.inclusion"))

#     end

#     it "should raise an InvalidSignature exception if an empty " \
#        "governing_document_file param is passed" do

#       expect {
#         put :update,
#             params: {
#                 application_id: funding_application.id,
#                 project: {
#                     governing_document_file: ""
#                 }
#             }
#       }.to raise_error(ActiveSupport::MessageVerifier::InvalidSignature)

#     end

#     it "should successfully update if a valid param is passed" do

#       put :update, params: {
#           application_id: funding_application.id,
#           project: {
#               governing_document_file: Rack::Test::UploadedFile.new(
#                   "#{Rails.root}/spec/fixtures/files/example.txt"
#               )
#           }
#       }

#       expect(response).to have_http_status(:redirect)
#       expect(response).to redirect_to(:funding_application_gp_project_governing_documents)

#       expect(assigns(:funding_application).project.errors.empty?).to eq(true)
#       expect(funding_application.project.governing_document_file.present?).to eq(true)

#     end

#   end

# end

require "rails_helper"

RSpec.describe Organisation::GoverningDocumentsController do

  login_user

  let(:organisation) {
    subject.current_user.organisations.first
  }

  describe "GET #show" do

    it "should render the page successfully for a valid organisation" do
      get :show,
          params: { organisation_id: organisation.id }
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

    it "should successfully update if a valid param is passed" do

      put :update, params: {
          organisation_id: organisation.id,
          organisation: {
              governing_document_file: Rack::Test::UploadedFile.new(
                  "#{Rails.root}/spec/fixtures/files/example.txt"
              )
          }
      }

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(organisation_governing_documents_question_path(organisation))

      expect(assigns(:organisation).errors.empty?).to eq(true)
      expect(organisation.reload.governing_document_file.present?).to eq(true)

    end

end
