# Controller for a page that asks for a description of the work an organisation does. 
class Organisation::OrgDescriptionController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  def update    
      redirect_to organisation_communities_that_org_serve_path
  end

  # # This method updates the org_description attributes
  # # of an organisation redirecting to :organisation_about if successful and
  # # re-rendering the :show method if unsuccessful
  # def update

  #   logger.info "Updating org_description for organisation ID: #{@organisation.id}"

  #   @organisation.validate_org_description = true

  #   @organisation.update(organisation_params)

  #   if @organisation.valid?

  #     logger.info "Finished updating org_description for organisation ID: #{@organisation.id}"

  #     if Flipper.enabled?(:import_existing_account_enabled)
  #       redirect_to organisation_communities_that_org_serve_path
  #     else
  #       redirect_to organisation_path
  #     end

  #   else

  #     logger.info 'Validation failed when attempting to update org_description' \
  #                   "for organisation ID: #{@organisation.id}"

  #     log_errors(@organisation)

  #     render :show

  #   end

  

  private

  def organisation_params
    params.require(:organisation).permit(:org_description)
  end

end
