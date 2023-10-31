# Controller for a page that asks for a company number.
class Organisation::CompanyNumberController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  def update
  redirect_to organisation_vat_registered_path
  end

  # This method updates the company_number attributes
  # of an organisation redirecting to :vat_registered if successful and
  # re-rendering the :show method if unsuccessful
  # def update

  #   logger.info "Updating company_number for organisation ID: #{@organisation.id}"

  #   @organisation.validate_company_number = true

  #   @organisation.update(organisation_params)

  #   if @organisation.valid?

  #     logger.info "Finished updating company_number for organisation ID: #{@organisation.id}"

  #     redirect_to :vat_registered

  #   else

  #     logger.info "Validation failed when attempting to update company_number for organisation ID: #{@organisation.id}"

  #     log_errors(@organisation)

  #     render :show

  #   end
  # end

  private

  def organisation_params
    params.require(:organisation).permit(:company_number)
  end

end
