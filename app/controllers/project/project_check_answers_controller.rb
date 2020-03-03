class Project::ProjectCheckAnswersController < ApplicationController
  include ProjectContext, ObjectErrorsLogger

  def update

    logger.info "Determining state of application before proceeding to declaration route " \
                  "for project ID: #{@project.id}"

    @project.validate_check_your_answers = true

    if @project.valid?

      logger.info "All mandatory fields completed for project ID: #{@project.id}, " \
                    "proceeding to declaration route"

      if current_user.organisation.org_type == "registered_company" ||
          current_user.organisation.org_type == "individual_private_owner_of_heritage"

        redirect_to :three_to_ten_k_project_confirm_declaration_get

      else

        redirect_to :three_to_ten_k_project_governing_docs_get

      end

    else

      logger.info "Validation failed when 'Check your answers' " \
                    "form was submitted for project ID: #{@project.id}"

      log_errors(@project)

      render :show

    end

  end

end
