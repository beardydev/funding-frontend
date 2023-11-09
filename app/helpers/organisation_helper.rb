module OrganisationHelper
  include OrganisationSalesforceApi

  MAX_RETRIES = 3

  # Checks for the presence of mandatory organisation parameters,
  # returning false if any are not present and true if all are
  # present
  #
  # @param [Organisation] organisation An instance of Organisation
  def complete_organisation_details?(organisation)

    [
        organisation.name.present?,
        organisation.line1.present?,
        organisation.townCity.present?,
        organisation.postcode.present?,
        organisation.org_type.present?
    ].all?

  end

  def complete_organisation_details_for_pre_application?(organisation)

    [
        organisation.name.present?,
        organisation.line1.present?,
        organisation.townCity.present?,
        organisation.postcode.present?,
        organisation.org_type.present?
    ].all?

  end

  # Checks for the presence of an organisation associated to a user
  # and creates one if none exists
  #
  # @param [User] user An instance of User
  def create_organisation_if_none_exists(user)

    # rubocop:disable Style/GuardClause
    unless user.organisations.any?

      logger.info "No organisation found for user ID: #{user.id}"

      create_organisation(user)

    else

      user.organisations.first

    end
    # rubocop:enable Style/GuardClause

  end

  # Creates an organisation and links this to the current_user
  #
  # @param [User] user An instance of User
  def create_organisation(user)

    organisation = user.organisations.create

    logger.info "Successfully created organisation ID: #{organisation.id}"

    organisation

  end

  # Populates an Organisation from the Salesforce Account.
  # Firstly calls:
  # update_existing_organisation_from_salesforce_details which
  # populates anything normally captured by FFE for a new organisation.
  #
  # Secondly calls:
  # update_org_with_medium_grant_questions which adds any organisation
  # information added as part of a medium grant.
  #
  # Thirdly, sets the organisation type to unknown.  SF and FFE org types
  # do not map.  And migrated cases could have different org types.
  #
  # Fourthly, checks that the populated org is now complete.  If so, then
  # saves and returns true.  Otherwise sends a support mail, and the result
  # remains false (though set to false again for code readability).
  #
  # @param [org] Organisation An instance of this class
  # @param [salesforce_account_id] String A reference for Salesforce Account Id
  def populate_migrated_org_from_salesforce(org, salesforce_account_id)

    result = false # Initialise.  Set to true upon success.

    # set salesforce_account_id in memory
    # update_existing_organisation_from_salesforce_details will save if OK.
    org.salesforce_account_id = salesforce_account_id

    update_existing_organisation_from_salesforce_details(org)

    update_org_with_medium_grant_questions(org)

    # type can't be populated from Salesforce as it conflates FFE values and
    # has its own types too.
    org.org_type = :unknown

    # Salesforce information may be incomplete, send mail if so.
    if complete_organisation_details?(org)

      org.save!

      Rails.logger.info("Successfully populated organisation " \
        "#{org.id} from existing Salesforce account " \
          "#{salesforce_account_id}.")

      result = true

    else

      send_incomplete_account_import_error_support_email(
        current_user.email,
        org
      )

      Rails.logger.info("Unsuccessfully populated organisation " \
        "#{org.id} from existing Salesforce account " \
          "#{salesforce_account_id}. " \
            "Org chosen was incomplete.")

      result = false

    end

    result

  end

  # Call Organisation API to retrieve existing organisation details
  # from salesforce using a SF account ID
  #
  # @param [String] Salesforce Account ID
  # @return [RestforceResponse] Organisation details found
  def retrieve_existing_salesforce_organisation(salesforce_account_id)
    client = OrganisationSalesforceApi.new
    return client.retrieve_existing_sf_org_details(salesforce_account_id)
  end
  
  # Method to retrieve and update latest org details from salesforce
  # aligning FFE with any salesforce changes.
  #
  # We don't update organisation details that are asked at the start
  # of the medium grant journey.  This is because these questions are
  # always asked as part of a medium grant and so a sync is not
  # necessary.  When we had these questions included, they were being
  # erroneously updated from Salesforce, wiping answers.
  #
  # @param [Organisation] organisation The organisation to update.
  #
  def update_existing_organisation_from_salesforce_details(organisation)

    retry_number = 0

    begin

      client = OrganisationSalesforceApi.new
      sf_details = client.retrieve_existing_sf_org_details(organisation.salesforce_account_id)

      populate_organisation_from_restforce_object(organisation, sf_details)

      organisation.save!

      update_salesforce_changes_checks(organisation)

      Rails.logger.info("Latest organisation details for id: " \
        "#{organisation.id} populated from salesforce_account_id: " \
          "#{organisation.salesforce_account_id}")

    rescue StandardError => e

      if retry_number < MAX_RETRIES

        retry_number +=1

        max_sleep_seconds = Float(2 ** retry_number)

        Rails.logger.info(
          "Will attempt update organisation details from salesforce " \
            "again, retry number #{retry_number} " \
              "after a sleeping for up to #{max_sleep_seconds} seconds"
        )

        sleep rand(0..max_sleep_seconds)

        retry

      else

        Rails.logger.error("Latest organisation details for id: " \
          "#{organisation.id} populated from salesforce_account_id: " \
            "#{organisation.salesforce_account_id} failed owing to " \
              "error: #{e.message}"
        )

        raise

      end
    end
  end

  # Method to retrieve and update latest medium grant org details
  # from salesforce aligning FFE with any salesforce changes.
  #
  # This method does not update FFE with organisation information
  # that is captured outside of the medium grant process.
  #
  # @param [Organisation] organisation The organisation to update.
  #
  def update_org_with_medium_grant_questions(organisation)
    retry_number = 0

    begin

      client = OrganisationSalesforceApi.new
      sf_details = client.retrieve_existing_sf_org_details(organisation.salesforce_account_id)

      organisation.board_members_or_trustees =
      sf_details.Number_Of_Board_members_or_Trustees__c

      organisation.vat_registered =
        convert_vat_registered_picklist(sf_details.Are_you_VAT_registered_picklist__c)

      organisation.vat_number =
        sf_details.VAT_number__c

      organisation.save!

      update_salesforce_changes_checks(organisation)

      Rails.logger.info("Latest medium grant related organisation details " \
        "for id: #{organisation.id} populated from salesforce_account_id: " \
          "#{organisation.salesforce_account_id}")

    rescue StandardError => e

      if retry_number < MAX_RETRIES

        retry_number +=1

        max_sleep_seconds = Float(2 ** retry_number)

        Rails.logger.info(
          "Will attempt to update medium grant related organisation details " \
            "from salesforce again, retry number #{retry_number} " \
                "after a sleeping for up to #{max_sleep_seconds} seconds"
        )

        sleep rand(0..max_sleep_seconds)

        retry

      else

        Rails.logger.error("Latest medium grant related organisation " \
          "details for id: #{organisation.id} populated from " \
            "salesforce_account_id: #{organisation.salesforce_account_id} " \
              "failed owing to error: #{e.message}"
        )

        raise

      end
    end

  end


  # Updates the salesforce_changes_check table if
  # updates have been pulled from Salesforce
  #
  # This function could be moved into SalesforceChangesCheck
  # model, if other models end up using this.
  #
  # @param [Organisation] organisation
  def update_salesforce_changes_checks(organisation)

    existing_row =
      SalesforceChangesCheck.find_by(record_id: organisation.id)

    if existing_row.present?

      existing_row.update!(
        time_salesforce_checked: DateTime.now
      )

    else

      SalesforceChangesCheck.create!(
        record_id: organisation.id,
        record_type: organisation.class,
        time_salesforce_checked: DateTime.now
      )

    end

  end

  # True if updates have been pulled from Salesforce today.
  #
  # This function could be moved into SalesforceChangesCheck
  # model, if other models end up using this.
  #
  # @param [Organisation] organisation
  def salesforce_checked_today?(organisation)

    record =
      SalesforceChangesCheck.find_by(record_id: organisation.id)

    record.present? ? record.updated_at.today? : false

  end

  # Method to convert salesforce VAT_registered type to FFE type
  #
  # @param [String] vat_registered The salesforce string denoting
  #                                 VAT_Register type.
  #
  #  @return [Boolean] boolean Value of VAT_Registered. Or nil if
  #                            'N/A' or if there is no match, such
  #                             as when SF set to 'None'
  def convert_vat_registered(vat_registered)

    case vat_registered
    when "Yes"
      return true
    when "No"
      return false
    when "N/A"
      return nil
    end
  end

  # Currently not used as org_types in SF and FFE do not align
  # This will be enhanced and used in future work
  def convert_org_type(org_type_string)

    case org_type_string
    when "Registered charity"
      return "registered_charity"
    when "Local authority'"
      return "local_authority"
    when "Registered company or Community Interest Company (CIC)" 
      return "registered_company"
    # when "community interest company"
    #   return "community_interest_company"
    when "Faith based or church organisation"
      return "faith_based_organisation"
    # when "church organisation"
    #   return "church_organisation"
    when "Community of Voluntary group"
      return "community_group"
    # when " voluntary group"
    #   return "voluntary_group"
    when "Private owner of heritage"
      return "individual_private_owner_of_heritage"
    when "Other organisation type"
      return "other"
    when "Other public sector organisation"
      return "other_public_sector_organisation"
    end
  end

  # Method to convert salesforce vat registered picklist value to FFE type
  #
  # @param [String] picklist_type A string containing a picklist value
  #
  # @return [String] picklist string A picklist string or nil
  #
  def convert_vat_registered_picklist(picklist_type)

    case picklist_type
    when 'Yes'
      picklist = true
    when 'No'
      picklist = false
    else
      picklist = nil
    end

  end

  # Takes an array of Organisations.  Returns true if all match using the
  # Organisation model's equality function (def == (other)).
  # @param [orgs_array] Array An array of Organisation objects.
  # @return [true/false] Boolean True if all match 
  def orgs_match?(orgs_array)

    result = orgs_array.all? { | org |  org == orgs_array.first}

    return result

  end

  # Checks if each of the orgs in the
  # passed array is complete
  #
  # @param [orgs] Array An Array of Organisation objects
  # @return [true/false] Boolean True if everything complete
  def orgs_are_complete?(orgs)

    orgs.each do |org|
      return false unless complete_organisation_details?(org)
    end

    return true

  end

  # Populates a FFE Organisation instance from a Salesforce
  # Restforce::Object for an Account.
  #
  # Used to sync FFE from Salesforce and
  # to partially populate potential organisations (for checking) when trying
  # to import an organisation from an existing SF account
  #
  # @param [org] Organisation An Organisation instance
  # @param [restforce_org] Restforce::Object An Account instance from SF
  #
  def populate_organisation_from_restforce_object(org, restforce_org)

    lines_array = ['', '', '']

    # BillingStreet nil when Account created with no address
    unless restforce_org&.BillingStreet.nil?
      lines_array = restforce_org&.BillingStreet.split(/\s*,\s*/)
    end

    org.name = restforce_org&.Name
    org.line1 = lines_array[0]
    org.line2 = lines_array[1]
    org.line3 = lines_array[2]

    org.townCity = restforce_org&.BillingCity
    org.county = restforce_org&.BillingState
    org.postcode = restforce_org&.BillingPostalCode
    org.company_number = restforce_org&.Company_Number__c
    org.charity_number = restforce_org&.Charity_Number__c

    #Currently not used as org_types in SF and FFE do not align
    # organisation.org_type = convert_org_type(restforce_org.Organisation_Type__c)

  end

end

# Returns an organisation to its unpopulated state
# Saves changes to the database
# @param [org] Organisation An instance of this class
def clear_org_data(org)
  org.line1 = nil
  org.line2 = nil
  org.line3 = nil
  org.townCity = nil
  org.county = nil
  org.postcode = nil
  org.company_number = nil
  org.charity_number = nil
  org.name = nil
  org.org_type = nil
  org.salesforce_account_id = nil
  org.custom_org_type = nil
  org.board_members_or_trustees = nil
  org.vat_registered = nil
  org.description = nil
  org.communities_that_org_serve = nil
  org.leadership_self_identity = nil
  org.number_of_employees = nil
  org.number_of_volunteers = nil
  org.volunteer_work_description = nil
  org.save!
end

def upload_org_to_salesforce(organisation)
  client = OrganisationSalesforceApi.new

  client.create_organisation_in_salesforce(organisation)
end
