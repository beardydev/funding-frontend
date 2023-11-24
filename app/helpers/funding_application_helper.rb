module FundingApplicationHelper
  include SalesforceApi
  include OrganisationSalesforceApi

  DELETED_TEXT = 'deleted by system'
  DELETED_EMAIL = 'deleted@deleted.com'

  # Method responsible for orchestrating the submission of a funding
  # application to Salesforce
  #
  # @param [FundingApplication] funding_application An instance of a
  #                                                 FundingApplication
  # @param [User] user An instance of a User
  # @param [Organisation] organisation An instance of an Organisation
  def send_funding_application_to_salesforce(
    funding_application,
    user,
    organisation
  )

    salesforce_api_client = SalesforceApiClient.new

    organisation_api_client = OrganisationSalesforceApiClient.new
    
    organisation.update(
      salesforce_account_id: 
      organisation_api_client.create_organisation_in_salesforce(
        organisation
      )
    )

    salesforce_references = salesforce_api_client.create_project(
      funding_application,
      user,
      organisation
    )

    funding_application.update(
      submitted_on: DateTime.now,
      salesforce_case_id: salesforce_references[:salesforce_project_reference],
      project_reference_number: salesforce_references[:external_reference],
      salesforce_case_number: salesforce_references[:external_reference].nil? ?
        nil :
        salesforce_references[:external_reference].chars.last(5).join
    )

    user.update(
      salesforce_contact_id: salesforce_references[:salesforce_contact_id]
    ) if user.salesforce_contact_id.nil?


  end

  # Method used to retrieve the link to the Standard Terms of Grant
  # based on the level of funding that has been awarded
  # @param funding_application [FundingApplication] An instance of
  #                                                 FundingApplication
  #
  # @return A string containing the link to the relevant Standard Terms
  #         of Grant
  def get_standard_terms_link(funding_application)

    if I18n.locale == :cy 
      standard_terms_link =
        'https://www.heritagefund.org.uk/cy/publications/standard-terms-grants' \
          '-3k-10k' if funding_application.is_3_to_10k?

      standard_terms_link =
        'https://www.heritagefund.org.uk/cy/publications/standard-terms-grants' \
          '-10k-100k' if funding_application.is_10_to_100k?

      standard_terms_link =
        'https://www.heritagefund.org.uk/cy/publications/standard-terms-grants' \
          '-100k-250k' if funding_application.is_100_to_250k?
    else
      standard_terms_link =
        'https://www.heritagefund.org.uk/publications/standard-terms-grants' \
          '-3k-10k' if funding_application.is_3_to_10k?

      standard_terms_link =
        'https://www.heritagefund.org.uk/publications/standard-terms-grants' \
          '-10k-100k' if funding_application.is_10_to_100k?

      standard_terms_link =
        'https://www.heritagefund.org.uk/publications/standard-terms-grants' \
          '-100k-250k' if funding_application.is_100_to_250k?
    end

    standard_terms_link

  end

  # Method used to retrieve the link to the Retrieving a Grant guidance
  # based on the level of funding that has been awarded
  # @param funding_application [FundingApplication] An instance of
  #                                                 FundingApplication
  #
  # @return A string containing the link to the relevant Retrieving a
  #         Grant guidance
  def get_receiving_a_grant_guidance_link(funding_application)

    if I18n.locale == :cy 
      receiving_a_grant_guidance_link =
        'https://www.heritagefund.org.uk/cy/funding/receiving-grant-guidance' \
          '-ps3000-ps10000' if funding_application.is_3_to_10k?

      receiving_a_grant_guidance_link =
        'https://www.heritagefund.org.uk/cy/funding/receiving-grant-guidance' \
          '-ps10000-ps100000' if funding_application.is_10_to_100k?

      receiving_a_grant_guidance_link =
        'https://www.heritagefund.org.uk/cy/funding/receiving-grant-guidance' \
          '-ps100000-ps250000' if funding_application.is_100_to_250k?

    else
      receiving_a_grant_guidance_link =
        'https://www.heritagefund.org.uk/funding/receiving-grant-guidance' \
          '-ps3000-ps10000' if funding_application.is_3_to_10k?

      receiving_a_grant_guidance_link =
        'https://www.heritagefund.org.uk/funding/receiving-grant-guidance' \
          '-ps10000-ps100000' if funding_application.is_10_to_100k?

      receiving_a_grant_guidance_link =
        'https://www.heritagefund.org.uk/funding/receiving-grant-guidance' \
          '-ps100000-ps250000' if funding_application.is_100_to_250k?
    end

    receiving_a_grant_guidance_link

  end

  # Method used to retrieve the link to the Retrieving a guidance on 
  # property ownership, 
  # based on the level of funding that has been awarded
  # @param funding_application [FundingApplication] An instance of
  #                                                 FundingApplication
  #
  # @return A string containing the link to the relevant guidance
  def get_receiving_guidance_property_ownership_link(funding_application)

    if I18n.locale == :cy 
      link =
      'https://www.heritagefund.org.uk/cy/funding/receiving-grant-guidance' \
        '-ps3000-ps10000#heading-8' if funding_application.is_3_to_10k?

      link =
        'https://www.heritagefund.org.uk/cy/funding/receiving-grant-guidance' \
          '-ps10000-ps100000#heading-10' if funding_application.is_10_to_100k?

      link =
        'https://www.heritagefund.org.uk/cy/funding/receiving-grant-guidance' \
          '-ps100000-ps250000#heading-10' if funding_application.is_100_to_250k?
    else
      link =
        'https://www.heritagefund.org.uk/funding/receiving-grant-guidance' \
          '-ps3000-ps10000#heading-8' if funding_application.is_3_to_10k?

      link =
        'https://www.heritagefund.org.uk/funding/receiving-grant-guidance' \
          '-ps10000-ps100000#heading-10' if funding_application.is_10_to_100k?

      link =
        'https://www.heritagefund.org.uk/funding/receiving-grant-guidance' \
          '-ps100000-ps250000#heading-10' if funding_application.is_100_to_250k?
    end
 
    link

  end

  # Method used to retrieve the link to the Retrieving 
  # programme application guidance.
  # Initialises link to larger grant levels, overwrites if under 10k
  # based on the level of funding that has been awarded
  # @param funding_application [FundingApplication] An instance of
  #                                                 FundingApplication
  #
  # @return A string containing the link to the relevant guidance
  def get_programme_application_guidance_link(funding_application)

    if I18n.locale == :cy 
      link =
      'https://www.heritagefund.org.uk/cy/node/111087' 
      
      link =
        'https://www.heritagefund.org.uk/cy/node/111086' \
            if funding_application.is_3_to_10k?
      
    else
      link =
        'https://www.heritagefund.org.uk/funding/' \
          'national-lottery-grants-heritage-10k-250k' 
        
      link =
        'https://www.heritagefund.org.uk/funding/' \
          'national-lottery-grants-heritage-2021/3-10k' \
            if funding_application.is_3_to_10k?
    end

    link

  end

  # Method used to determine whether or not the applicant
  # is also a legal signatory for a given funding application
  #
  # @param funding_application [FundingApplication] An instance of
  #                                                 FundingApplication
  # @param applicant [User] An instance of User
  #
  # @return A Boolean value indicating whether or not the applicant
  #         is also a legal signatory for the given funding application
  def is_applicant_legal_signatory?(funding_application, applicant)

    get_when_signatory_is_applicant(funding_application, applicant).present?

  end

  # Method to find a row on funding_application_legal_signatories
  # Where signatory is also the applicant.
  #
  # @param funding_application [FundingApplication] An instance of
  #                                                 FundingApplication
  # @param applicant [User] An instance of User
  #
  # @return [FundingApplicationsLegalSig] signatory_is_applicant_join_row. 
  #                                       Or nil if not found
  #
  def get_when_signatory_is_applicant(funding_application, applicant)

    signatory_is_applicant_join_row = nil

    funding_application.funding_applications_legal_sigs.each do |join_row|

      if applicant.email&.strip&.upcase == 
        join_row.legal_signatory.email_address&.strip&.upcase

        signatory_is_applicant_join_row = join_row
        break

      end

    end

    signatory_is_applicant_join_row

  end

  # Return true if the grant award is up to and including 100k.
  #
  # @param grant award [Integer] Grant award amount
  #
  # @return result Boolean value indicating award falls in threshold
  def up_to_100k(grant_award)

    if grant_award
      result = grant_award <= 100000
    else
      result = false      
    end

    result 

  end

  # Return true if the grant award is over 100k.
  #
  # @param grant award [Integer] Grant award amount
  #
  # @return result Boolean value indicating award falls in threshold
  def over_100k(grant_award)

    if grant_award
      result = grant_award > 100000
    else
      result = false      
    end

    result 

  end

  # Uploads any additional evidence provided by a signatory during the
  # Agreements process.  Then uploads the sigs themselves.
  #
  # @param grant award [FundingApplication] an instance of this class
  def upload_signatories_and_evidence_to_sf(funding_application)

    if @funding_application.additional_evidence_files.any?

      logger.info "Uploading additional evidence files for " \
        "funding_application ID: #{@funding_application.id}"
      upload_additional_evidence_files(@funding_application)

    end

    logger.info "Uploading signatories for " \
      "funding_application ID: #{@funding_application.id}"
    upload_signatories_to_salesforce(@funding_application)
   
    logger.info "signatories and evidence submitted to salesforce for " \
      "funding_application ID: #{@funding_application.id}"

  end

  # deletes
  #
  # @param grant award [FundingApplication] an instance of this class
  def remove_personal_data_from_signatories(funding_application)
    funding_application.legal_signatories.each do |ls|
      ls.name = DELETED_TEXT
      ls.email_address = DELETED_EMAIL
      ls.phone_number = DELETED_TEXT
      ls.role = DELETED_TEXT
      ls.save!
      logger.info "Personal data removed for legal_signatory ID: #{ls.id} "
    end
  end

  # Checks the award_type for a funding_application
  # Sets if the award_type is nil after the legal agreements
  # process can start.
  #
  # This is the only place the award_type can be set.
  # This should be set ASAP after the when the legal agreement
  # process starts, and no earlier.
  #
  # Calls to this function are currently made when
  # - funding_application_context.rb finds a valid application
  # - legal_agreement_context.rb finds a valid application
  # - A new FundingApplication is created for a large project
  #
  # @param grant award [FundingApplication] an instance of this class
  def check_award_type(funding_application)

    if (funding_application.award_type.nil? || \
      funding_application.award_type_unknown?) && \
        funding_application.submitted_on.present?

      salesforce_api_client = SalesforceApiClient.new

      awarded = salesforce_api_client.is_project_awarded_using_case_id(
        funding_application.salesforce_case_id
      )

      set_award_type(funding_application) if awarded

    end

  end

  # Retrieves the total project costs for an application
  #
  # @param salesforce_case_id [String] salesforce case ID associated to a
  #                                                 funding application
  # @return total costs [Int] total costs for a given project
  def get_total_project_costs(salesforce_case_id)
    salesforce_api_client = SalesforceApiClient.new
    salesforce_api_client.get_total_project_costs(salesforce_case_id)
  end

  # Retrieves the total agreed project costs for a development application
  #
  # @param salesforce_case_id [String] salesforce case ID associated to a
  #                                                 funding application
  # @return total costs [Int] total agreed costs for a given project
  def get_agreed_project_costs_dev(salesforce_case_id)
    salesforce_api_client = SalesforceApiClient.new
    salesforce_api_client.get_agreed_project_costs_dev(salesforce_case_id)
  end

  private

  # Private function.  Only called by check_award_type.
  # This should be set when the legal agreement process starts.
  # For older applications where this had not happened,
  # check_award_type will only set sometime after the legal
  # agreement process has started.
  #
  # Sets an enumerated type for the passed instance of
  # FundingApplication.  Used to determine what behaviour
  # FFE should demonstrate based on grant level.
  #
  # When a record type of development or delivery is found, that
  # is all we need, and award amount is disregarded.
  # If the record type is not for development or delivery, then
  # we use the award amount to set an award_type based on
  # grant level.
  #
  # When an agreements journey starts, the grant
  # level must remain the same, as far as FFE is concerned,
  # so that the content is consiustent in the upcoming user journeys.
  #
  # @param grant award [FundingApplication] an instance of this class
  def set_award_type(funding_application)

    funding_application.award_type = :award_type_unknown

    salesforce_api_client = SalesforceApiClient.new

    award_hash =
      salesforce_api_client.get_grant_level_details_for_project(
        funding_application.salesforce_case_id
      )

    if award_hash[:record_type] == 'Large_Development_250_500k'

      funding_application.update!(award_type: :dev_to_100k) \
        if up_to_100k(award_hash[:dev_grant_award])

      funding_application.update!(award_type: :dev_over_100k) \
        if over_100k(award_hash[:dev_grant_award])

    elsif award_hash[:record_type] == 'Large'

      funding_application.update!(award_type: :del_250k_to_5mm)

    elsif award_hash[:record_type] == 'Small_Grant_3_10k'

      funding_application.update!(award_type: :is_3_to_10k)

    elsif award_hash[:record_type] == 'Medium'

      funding_application.update!(award_type: :is_10_to_100k) \
        if up_to_100k(award_hash[:grant_award])

      funding_application.update!(award_type: :is_100_to_250k) \
        if over_100k(award_hash[:grant_award])

    end
      
    if funding_application.award_type_unknown?
      raise StandardError.new(
        "Could not identify an award type for: #{funding_application.id}"
      )
  
    end

  end

  # Queries funding_application and salesforce to determine 
  # if the first 50% payment has been completed for an M1 or Dev < 100K app.
  #
  # @param funding_application [FundingApplication] 
  #                                             funding application to query
  #                                                 
  # @return is first 50% payment complete [Boolean] 
  def first_50_percent_payment_completed?(funding_application)

    if funding_application.is_10_to_100k? || funding_application.dev_to_100k?

      fifty_form =
        funding_application.payment_requests.order(:created_at).first

      salesforce_api_client = SalesforceApiClient.new

      fifty_form.present? ?
        salesforce_api_client.is_form_completed?(fifty_form.id) :  false

    end

  end

  # Checks to see if the status of a funding app indicates
  # the application is in not in a payment journey.
  #
  # @param funding_application [FundingApplication] 
  #                                                funding application to query
  #                                                 
  # @return is not in payment journey [Boolean] 
  def not_in_payments?(funding_application)

    !funding_application&.payment_can_start? &&
      !funding_application&.m1_40_payment_can_start? &&
        !funding_application&.m1_40_payment_complete? &&
          !funding_application&.dev_40_payment_can_start? &&
            !funding_application&.dev_40_payment_complete?

  end

end
