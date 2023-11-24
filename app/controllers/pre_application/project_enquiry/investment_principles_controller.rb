# Controller for the project enquiry 'investment principles' page
class PreApplication::ProjectEnquiry::InvestmentPrinciplesController < ApplicationController
  include PreApplicationContext, ObjectErrorsLogger
  
  # This method updates the investment_principles attribute of a pa_project_enquiry,
  # redirecting to : pre_application_project_enquiry_who_will_be_involved if successful and
  # re-rendering :show method if unsuccessful
  def update

    logger.info 'Updating investment_principles for ' \
                "pa_project_enquiry ID: #{@pre_application.pa_project_enquiry.id}"

    @pre_application.pa_project_enquiry.validate_investment_principles = true

    if @pre_application.pa_project_enquiry.update(pa_project_enquiry_params)

      logger.info 'Finished updating investment_principles for pa_project_enquiry ID: ' \
                  "#{@pre_application.pa_project_enquiry.id}"

      redirect_to(:pre_application_project_enquiry_who_will_be_involved)

    else

      logger.info 'Validation failed when attempting to update investment_principles ' \
                  " for pa_project_enquiry ID: #{@pre_application.pa_project_enquiry.id}"

      log_errors(@pre_application.pa_project_enquiry)

      render(:show)

    end
  
  end

  def pa_project_enquiry_params

    params.require(:pa_project_enquiry).permit(:investment_principless)

  end

end
