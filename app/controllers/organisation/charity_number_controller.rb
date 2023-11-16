# This controller ensures the organisation charity number is captured
class Organisation::CharityNumberController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  # This method updates the charity_number attributes
  # of an organisation redirecting to :company_number if successful and
  # re-rendering the :show method if unsuccessful
  def update
    logger.info "Updating charity_number for organisation ID: #{@organisation.id}"

    @organisation.assign_attributes(organisation_params)

    # Clear charity_number if has_charity_number is 'no'
    if params[:organisation][:has_charity_number] == 'no'
      @organisation.charity_number = nil
    end

    # Check if has_charity_number is either 'yes' or 'no'
    unless ['yes', 'no'].include?(params[:organisation][:has_charity_number])
      @organisation.errors.add(:has_charity_number, I18n.t('charity_number.errors.blank'))
      log_errors(@organisation)
      render :show
      return
    end

    # If has_charity_number is 'yes', ensure charity_number is provided
    if params[:organisation][:has_charity_number] == 'yes' && @organisation.charity_number.blank?
      @organisation.errors.add(:charity_number, I18n.t('charity_number.errors.text_field_blank'))
      log_errors(@organisation)
      render :show
      return
    end

    if @organisation.save(context: :charity_number_update)
      logger.info "Finished updating charity_number for organisation ID: #{@organisation.id}"
      redirect_to organisation_company_number_path
    else
      log_errors(@organisation)
      render :show
    end
  end

  private

  def organisation_params
    params.require(:organisation).permit(:charity_number, :has_charity_number)
  end
end
