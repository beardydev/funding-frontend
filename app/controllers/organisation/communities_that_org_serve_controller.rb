# Controller for a page that asks an about the communities the org serves.
class Organisation::CommunitiesThatOrgServeController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  # This method updates the communities_that_org_serve attributes
  # of an organisation redirecting to :charity_number if successful and
  # re-rendering the :show method if unsuccessful
  def update
    logger.info "Updating communities_that_org_serve for organisation ID: #{@organisation.id}"
  
    @organisation.validate_communities_that_org_serve = true
  
    communities_params = organisation_params[:communities_that_org_serve] || []
    @organisation.communities_that_org_serve = communities_params.reject(&:blank?)
  
    # Now update the organisation object with the already-set communities_that_org_serve
    if @organisation.save
      logger.info "Finished updating communities_that_org_serve for organisation ID: #{@organisation.id}"
      redirect_to organisation_leadership_self_identify_path
    else
      log_errors(@organisation)
      render :show
    end
  end
  

  private

  def organisation_params
    params.fetch(:organisation, {}).permit(communities_that_org_serve: [])
  end

end
