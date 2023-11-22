module PreApplicationHelper
  include SalesforceApi
  include OrganisationSalesforceApi
  include Mailers::PefMailerHelper
  include Mailers::EoiMailerHelper
  
  # Method to orchestrate sending a pre-application to Salesforce
  # Determines whether the pre-application is an project enquiry or expression of interest,
  # then takes specific actions for them
  # After each Salesforce record is completed, the Salesforce reference is written back to
  # the associated PaProjectEnquiry, PaExpressionOfInterest, Organisation or User instance.
  #
  # @param [PreApplication] pre_application An instance of PreApplication
  # @param [User] user An instance of User
  # @param [Organisation] organisation An instance of Organisation
  def send_pre_application_to_salesforce(pre_application, user, organisation)

    salesforce_api_client = SalesforceApiClient.new
    
    organisation_api_client = OrganisationSalesforceApiClient.new

    organisation.update(salesforce_account_id: 
      organisation_api_client.create_organisation_in_salesforce(
        organisation
      )
    )

    if pre_application.pa_project_enquiry.present?

      salesforce_references = salesforce_api_client.create_project_enquiry(
        pre_application.pa_project_enquiry,
        user,
        organisation
      )

      pre_application.pa_project_enquiry.update(
        salesforce_project_enquiry_id: salesforce_references[:salesforce_project_enquiry_id],
        salesforce_pef_reference: salesforce_references[:salesforce_project_enquiry_reference]
      ) if pre_application.pa_project_enquiry.salesforce_project_enquiry_id.nil?

    end

    if pre_application.pa_expression_of_interest.present?

      salesforce_references = salesforce_api_client.create_expression_of_interest(
        pre_application.pa_expression_of_interest,
        user,
        organisation
      )

      pre_application.pa_expression_of_interest.update(
        salesforce_expression_of_interest_id: salesforce_references[:salesforce_expression_of_interest_id],
        salesforce_eoi_reference: salesforce_references[:salesforce_expression_of_interest_reference]
      ) if pre_application.pa_expression_of_interest.salesforce_expression_of_interest_id.nil?

    end

    queue_submission_confirmation_email(pre_application)

    pre_application.update(
      submitted_on: DateTime.now
    )

    user.update(
      salesforce_contact_id: salesforce_references[:salesforce_contact_id]
    ) if user.salesforce_contact_id.nil?

    organisation.update(
      salesforce_account_id: salesforce_references[:salesforce_account_id]
    ) if organisation.salesforce_account_id.nil?
    
  end

  # Method to forward user preferences to Salesforce
  #
  # @param [PreApplication] pre_application An instance of PreApplication
  # @param [User] user An instance of User
  def send_pre_application_user_preferences_to_salesforce(pre_application, user)

    salesforce_api_client = SalesforceApiClient.new

    salesforce_api_client.update_project_enquiry_can_contact_applicant(
      pre_application.pa_project_enquiry,
      user
    ) if pre_application.pa_project_enquiry.present?

    salesforce_api_client.update_expression_of_interest_can_contact_applicant(
      pre_application.pa_expression_of_interest,
      user
    ) if pre_application.pa_expression_of_interest.present?

    salesforce_api_client.update_agrees_to_user_research(user) 

  end

  private

  # Method responsible for queuing the relevant NotifyMailer submission confirmation email
  #
  # @param [PreApplication] pre_application An instance of a PreApplication object
  def queue_submission_confirmation_email(pre_application)

    logger.info('Queuing pre-application submission confirmation email...')

    project_enquiry_submission_confirmation(
      pre_application.user.email,
      pre_application.pa_project_enquiry.salesforce_pef_reference
    ) if pre_application.pa_project_enquiry.present?

    expression_of_interest_submission_confirmation(
      pre_application.user.email,
      pre_application.pa_expression_of_interest.salesforce_eoi_reference
    ) if pre_application.pa_expression_of_interest.present?

    logger.info('Completed queuing of pre-application submission confirmation email')

  end

end
