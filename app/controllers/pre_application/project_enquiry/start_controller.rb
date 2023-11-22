# Controller for the project enquiry 'start' page
class PreApplication::ProjectEnquiry::StartController < ApplicationController
  include OrganisationHelper
  include PreApplicationHelper
  before_action :authenticate_user!

  # Method used to manage the creation and orchestration of the
  # PaProjectEnquiry journey
  def update

    organisation = current_user.organisations.first

    if complete_organisation_details?(organisation)

      logger.info "Organisation details complete for #{organisation.id}"

      create_pre_application_and_project_enquiry(current_user,  organisation)

      redirect_to(
        pre_application_project_enquiry_previous_contact_path(
          @pre_application.id
        )
      )

    else

      logger.info "Organisation details not complete for #{organisation.id}"

      redirect_to organisation_organisation_name_path(organisation.id)

    end
  
  end

  private
  
  # Method responsible for creating a PreApplication object and
  # an associated PaProjectEnquiry object
  #
  # @param [User] user An instance of a User
  # @param [Organisation] organisation An instance of an Organisation
  def create_pre_application_and_project_enquiry(user, organisation)

    @pre_application = PreApplication.create(
      organisation_id: organisation.id,
      user_id: user.id
    )
  
    PaProjectEnquiry.create(pre_application_id: @pre_application.id)

  end

end
