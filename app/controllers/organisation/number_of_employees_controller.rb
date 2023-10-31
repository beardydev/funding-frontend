# Controller for a page that asks how many employees an organisation has. 
class Organisation::NumberOfEmployeesController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  def update
    redirect_to organisation_number_of_volunteers_path
  end

  # This method updates the number_of_employees attribute of an organisation,
  # redirecting to :number_of_volunteers if successful and re-rendering
  # :show method if unsuccessful
  # def update

  #   logger.info "Updating number_of_employees for organisation ID: #{@organisation.id}"

  #   @organisation.validate_number_of_employees = true

  #   @organisation.update(organisation_params)

  #   if @organisation.valid?

  #     logger.info "Finished updating number_of_employees for organisation ID: #{@organisation.id}"

  #     redirect_to redirect_to organisation_number_of_volunteers_path

  #   else

  #     logger.info "Validation failed when attempting to update number_of_employees for organisation ID: #{@organisation.id}"

  #     log_errors(@organisation)

  #     render :show

  #   end
  # end

  private

  def organisation_params
    params.require(:organisation).permit(:number_of_employees)
  end

end
