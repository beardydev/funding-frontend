# Controller for a page that asks whether an org is VAT registered
# And captures the VAT number if it is
class Organisation::VatRegisteredController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  def show
    @organisation = current_user.organisations.first
  end

  # This method updates the vat_registered attribute of an
  # organisation, redirecting to
  # :TODO if
  # successful and re-rendering :show method if unsuccessful
  def update

    @organisation = current_user.organisations.first

    logger.info(
      'Updating vat_registered for ' \
      "organisation ID: #{@organisation.id}"
    )

    @organisation.validate_vat_registered = true

    clear_or_validate_vat_number(@organisation, params)

    @organisation.update(organisation_params)

    if @organisation.valid?

      logger.info(
        'Finished updating vat_registered and vat_number ' \
        "for organisation ID: #{@organisation.id}"
      )

      redirect_to organisation_board_members_or_trustees_path

    else

      logger.info(
        'Validation failed when attempting to update ' \
        "vat for organisation ID: #{@organisation.id}"
      )

      log_errors(@organisation)

      render :show

    end

  end

  private

  def organisation_params

    params.require(:organisation).permit(:vat_registered, :vat_number)

  end

  # If the organisation is not VAT registered, then we
  # should clear any existing VAT number, otherwise we
  # should validate the incoming VAT number
  #
  # @param [Organisation] organisation An instance of an Organisation
  # @param [Params] params The incoming form parameters
  def clear_or_validate_vat_number(organisation, params)

    params[:organisation][:vat_number] = nil if
      params[:organisation][:vat_registered] == 'false'

    @organisation.validate_vat_number = true if
      params[:organisation][:vat_registered] == 'true'

  end

end
