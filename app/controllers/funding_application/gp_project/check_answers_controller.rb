class FundingApplication::GpProject::CheckAnswersController < ApplicationController
  include FundingApplicationContext, ObjectErrorsLogger

  # This method redirects a user based on whether or not the mandatory project
  # fields have been populated, redirecting where necessary based on the
  # organisation type if successful, or re-rendering :show method if
  # unsuccessful
  def update

    logger.info "Determining state of application before proceeding to " \
                "declaration route for project ID: #{@funding_application.project.id}"

    @funding_application.project.validate_check_your_answers = true

    if @funding_application.project.valid?

      logger.info "All mandatory fields completed for project ID: " \
                  "#{@funding_application.project.id}"

      # if current_user.organisations.first.org_type == "registered_company" ||
      #   current_user.organisations.first.org_type ==
      #       "individual_private_owner_of_heritage"

      #   logger.info "Organisation is either a registered company or an " \
      #               "individual private owner of heritage, redirecting to " \
      #               "accounts page"

      #   redirect_to :funding_application_gp_project_accounts

      # else

      #   logger.info "Redirecting to governing documents page"

      #   redirect_to :funding_application_gp_project_governing_documents

      # end

              redirect_to :funding_application_gp_project_accounts


    else

      logger.info "Validation failed when 'Check your answers' " \
                    "form was submitted for project ID: #{@funding_application.project.id}"

      log_errors(@funding_application.project)

      render :show

    end

  end

end
