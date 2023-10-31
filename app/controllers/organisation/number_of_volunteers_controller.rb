# Controller for a page that asks how many volunteers an organisation has. 
class Organisation::NumberOfVolunteersController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  def update
    redirect_to organisation_volunteer_work_description_path
  end

  # This method updates the number_of_volunteers attribute of an organisation,
  # redirecting to :volunteer_work_description if successful and re-rendering
  # :show method if unsuccessful
  # def update

  #   logger.info "Updating number_of_volunteers for organisation ID: #{@organisation.id}"

  #   @organisation.validate_number_of_volunteers = true

  #   @organisation.update(organisation_params)

  #   if @organisation.valid?

  #     logger.info "Finished updating number_of_volunteers for organisation ID: #{@organisation.id}"

  #     redirect_to :volunteer_work_description

  #   else

  #     logger.info "Validation failed when attempting to update number_of_volunteers for organisation ID: #{@organisation.id}"

  #     log_errors(@organisation)

  #     render :show

  #   end
  # end

  private

  def organisation_params
    params.require(:organisation).permit(:number_of_volunteers)
  end

end
