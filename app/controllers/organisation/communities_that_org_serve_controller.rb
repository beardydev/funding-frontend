# Controller for a page that asks which communities the organisation serves.
class Organisation::CommunitiesThatOrgServeController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  # This method updates the communities_that_org_serve. attributes
  # of an organisation redirecting to :leadership_self_identify if successful and
  # re-rendering the :show method if unsuccessful
  def update
    logger.info "Updating communities_that_org_serve for organisation ID: #{@organisation.id}"

    @organisation.update(organisation_params)

    if @organisation.valid?
      logger.info "Finished updating communities_that_org_serve for organisation ID: #{@organisation.id}"
      redirect_to organisation_leadership_self_identify_path
    else
      log_errors(@organisation)
      render :show
    end
  end

  private

  def organisation_params
    params.fetch(:organisation, {}).permit(communities_that_org_serve: [], communities_that_org_serve_none: [])
  end

end
