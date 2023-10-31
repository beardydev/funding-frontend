# Controller for a page that asks for a description of the work an organisations volunteers do 
class Organisation::VolunteerWorkDescriptionController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  def update
    redirect_to organisation_governing_documents_path
  end

  # This method updates the volunteer_work_description attribute of an organisation,
  # redirecting to :governing_documents if successful and re-rendering
  # :show method if unsuccessful
  # def update

  #   logger.info "Updating volunteer_work_description for organisation ID: #{@organisation.id}"

  #   @organisation.validate_volunteer_work_description = true

  #   @organisation.update(organisation_params)

  #   if @organisation.valid?

  #     logger.info "Finished updating volunteer_work_description for organisation ID: #{@organisation.id}"

  #     redirect_to :governing_documents

  #   else

  #     logger.info "Validation failed when attempting to update volunteer_work_description for organisation ID: #{@organisation.id}"

  #     log_errors(@organisation)

  #     render :show

  #   end
  # end

  private

  def organisation_params
    params.require(:organisation).permit(:volunteer_work_description)
  end

end
