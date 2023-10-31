# Controller for a page that asks for a charity number.
class Organisation::CharityNumberController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  def update
    redirect_to organisation_company_number_path
  end

  # This method updates the charity_number attribute of an organisation,
  # redirecting to :company_number if successful and re-rendering
  # :show method if unsuccessful
  # def update

  #   logger.info "Updating charity_number for organisation ID: #{@organisation.id}"

  #   @organisation.validate_charity_number = true

  #   @organisation.update(organisation_params)

  #   if @organisation.valid?

  #     logger.info "Finished updating charity_number for organisation ID: #{@organisation.id}"

  #     redirect_to organisation_company_number_path

  #   else

  #     logger.info "Validation failed when attempting to update charity_number for organisation ID: #{@organisation.id}"

  #     log_errors(@organisation)

  #     render :show

  #   end
  # end


  private

  def organisation_params
    params.require(:organisation).permit(:charity_number)
  end

end
