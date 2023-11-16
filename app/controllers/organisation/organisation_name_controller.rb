# Controller for a page that asks for a company number.
class Organisation::OrganisationNameController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  # This method updates the name attributes
  # of an organisation redirecting to :postcode_path if successful and
  # re-rendering the :show method if unsuccessful
  def update

    logger.info "Updating name for organisation ID: #{@organisation.id}"

    @organisation.validate_name = true

    @organisation.update(organisation_params)

    if @organisation.valid?

      logger.info "Finished updating org_description for organisation ID: #{@organisation.id}"

      if Flipper.enabled?(:import_existing_account_enabled)
        redirect_to postcode_path(type: 'organisation', id: current_user.organisations.first.id)
      else
        redirect_to organisation_path
      end

    else

      logger.info 'Validation failed when attempting to update name' \
                    "for organisation ID: #{@organisation.id}"

      log_errors(@organisation)

      render :show

    end

  end

  def organisation_params
    params.require(:organisation).permit(:name)
  end

end  
