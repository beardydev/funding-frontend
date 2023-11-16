# This controller ensures the organisation charity number is captured
class Organisation::CompanyNumberController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  # This method updates the company_number attributes
  # of an organisation redirecting to :vat_registered if successful and
  # re-rendering the :show method if unsuccessful
  def update
    logger.info "Updating company_number for organisation ID: #{@organisation.id}"

    @organisation.assign_attributes(organisation_params)

    # Clear company_number if has_company_number is 'no'
    if params[:organisation][:has_company_number] == 'no'
      @organisation.company_number = nil
    end

    # Check if has_company_number is either 'yes' or 'no'
    unless ['yes', 'no'].include?(params[:organisation][:has_company_number])
      @organisation.errors.add(:has_company_number, I18n.t('company_number.errors.blank'))
      log_errors(@organisation)
      render :show
      return
    end

    # If has_company_number is 'yes', ensure company_number is provided
    if params[:organisation][:has_company_number] == 'yes' && @organisation.company_number.blank?
      @organisation.errors.add(:company_number, I18n.t('company_number.errors.text_field_blank'))
      log_errors(@organisation)
      render :show
      return
    end

    if @organisation.save(context: :company_number_update)
      logger.info "Finished updating company_number for organisation ID: #{@organisation.id}"
      redirect_to organisation_vat_registered_path
    else
      log_errors(@organisation)
      render :show
    end
  end

  private

  def organisation_params
    params.require(:organisation).permit(:company_number, :has_company_number)
  end
end
