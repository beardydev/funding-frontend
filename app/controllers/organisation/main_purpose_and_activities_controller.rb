# Controller for a page that asks for a description of the work an organisation does. 
class Organisation::MainPurposeAndActivitiesController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger


  def show()
    
  end
  # This method updates the main_purpose_and_activities attributes
  # of an organisation redirecting to :organisation_about if successful and
  # re-rendering the :show method if unsuccessful
  def update

    logger.info "Updating main_purpose_and_activities for organisation ID: #{@organisation.id}"

    @organisation.validate_main_purpose_and_activities = true

    @organisation.update(organisation_params)

    if @organisation.valid?

      logger.info "Finished updating main_purpose_and_activities for organisation ID: #{@organisation.id}"

      redirect_to organisation_communities_that_org_serve_path
      
    else

      logger.info 'Validation failed when attempting to update main_purpose_and_activities' \
                    "for organisation ID: #{@organisation.id}"

      log_errors(@organisation)

      render :show

    end
  end  

  private

  def organisation_params
    params.require(:organisation).permit(:main_purpose_and_activities)
  end

end
