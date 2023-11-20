# Controller for a page that asks an how an organisations leadership self identifies.
class Organisation::LeadershipSelfIdentifyController < ApplicationController
  include OrganisationContext
  include ObjectErrorsLogger

  # This method updates the leadership_self_identify attributes
  # of an organisation redirecting to :charity_number if successful and
  # re-rendering the :show method if unsuccessful
  def update
    logger.info "Updating leadership_self_identify for organisation ID: #{@organisation.id}"

    @organisation.validate_leadership_self_identify = true

    leadership_params = organisation_params[:leadership_self_identify] || []
    @organisation.leadership_self_identify = leadership_params.reject(&:blank?)

    if @organisation.save
      logger.info "Finished updating leadership_self_identify for organisation ID: #{@organisation.id}"
      redirect_to organisation_charity_number_path
    else
      log_errors(@organisation)
      render :show
    end
  end

  private

  def organisation_params
    params.fetch(:organisation, {}).permit(leadership_self_identify: [])
  end
end
