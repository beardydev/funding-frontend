# Controller for a page that asks for details on the type of organisation applying.
class Organisation::TypeController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  # This method updates the org_type attribute of an organisation,
  # redirecting to :org_description if successful and re-rendering
  # :show method if unsuccessful
  def update

    logger.info "Updating org_type for organisation ID: #{@organisation.id}"

    @organisation.validate_org_type = true

    @organisation.update(organisation_params)

    if @organisation.valid?

      logger.info "Finished updating org_type for organisation ID: #{@organisation.id}"

      redirect_to organisation_org_description_path(organisation_id: @organisation.id)

    else

      logger.info "Validation failed when attempting to update org_type for organisation ID: #{@organisation.id}"

      log_errors(@organisation)

      render :show

    end
  end

  private

  def organisation_params
    params.fetch(:organisation, {}).permit(:org_type)
  end
end
