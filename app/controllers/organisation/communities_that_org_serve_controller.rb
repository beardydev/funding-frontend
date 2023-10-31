# Controller for a page that asks about the communities the organisation serves.
class Organisation::CommunitiesThatOrgServeController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

def update
  redirect_to organisation_leadership_self_identify_path
end
  # This method updates the communities_that_org_serve attributes
  # of an organisation redirecting to :communities_that_org_serve if successful and
  # re-rendering the :show method if unsuccessful
  # def update

  #   logger.info "Updating communities_that_org_serve for organisation ID: #{@organisation.id}"

  #   @organisation.validate_communities_that_org_serve = true

  #   @organisation.update(organisation_params)

  #   if @organisation.valid?

  #     logger.info "Finished updating communities_that_org_serve for organisation ID: #{@organisation.id}"

  #     redirect_to :organisation_leadership_self_identity_path

  #   else

  #     logger.info "Validation failed when attempting to update communities_that_org_serve for organisation ID: #{@organisation.id}"

  #     log_errors(@organisation)

  #     render :show

  #   end
  # end

  private

  def organisation_params
    params.require(:organisation).permit(:communities_that_org_serve)
  end

end
