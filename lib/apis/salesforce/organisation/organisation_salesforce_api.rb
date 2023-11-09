module OrganisationSalesforceApi

  class OrganisationSalesforceApi
    include SalesforceApiHelper

    # Overrides the .new() method, allowing us to initialise a Restforce client
    # when the class is instantiated
    def initialize

      initialise_client

    end

    # Method to upsert a Salesforce Organisation record. Calling function
    # should handle exceptions/retries.
    #
    # @param [Organisation] organisation An instance of an Organisation object
    #
    # @return [String] A salesforce id for the Account (Organisation is an alias of Account)
    def create_organisation_in_salesforce(organisation)

      salesforce_account_id = find_matching_account_for_organisation(organisation)

      if salesforce_account_id.nil?
        salesforce_account_id = upsert_account_by_organisation_id(organisation)
      else
        upsert_account_by_salesforce_id(organisation, salesforce_account_id)    
      end

      Rails.logger.info(
        "Upserted an Account record in Salesforce with reference: #{salesforce_account_id}"
      )

      salesforce_account_id

    end

    # Method to retrieve latest org details from salesforce
    #
    # @param [String] salesforce_account_id Salesforce Id for Account reqd.
    #
    # @return [Hash] restforce_response, Returns a hash containing salesforce
    #                                     field Keys and values.
    def retrieve_existing_sf_org_details(salesforce_account_id)

      restforce_response = []

      query_string = "SELECT " \
        "Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, " \
          "Company_Number__c, Charity_Number__c, organisation_description__c, "\
            "Organisation_Type__c, Communities_that_org_serves__c, " \
              "Are_you_VAT_registered_picklist__c, VAT_number__c, "\
                "leadership_self_identify__c, " \
                  "Number_Of_Board_members_or_Trustees__c, "\
                    "NumberOfEmployees,  " \
                      "Number_of_volunteers__c,  Volunteer_work_description__c " \
                        "FROM Account " \
                          "where Id = '#{salesforce_account_id}' " 

      restforce_response = run_salesforce_query(query_string, 
        "retrieve_existing_sf_org_details", salesforce_account_id) \
          if query_string.present?

      restforce_response.first

    end


    # Updates VAT information for an existing organisation
    # This can be vat registered status and the associated
    # VAT number.
    #
    # @param [String] salesforce_acc_id Salesforce Account Id
    # @param [String] vat_number New vat_number or nil
    # @param [String] new_vat_registered_status Should be Yes or No (Not N/A)
    #
    def change_organisation_vat_status(salesforce_acc_id,
      vat_number, new_vat_registered_status)

      retry_number = 0

      Rails.logger.info("change_organisation_vat_status called for " \
        "salesforce account id: #{salesforce_acc_id}")

      begin

        @client.update!(
          'Account',
          Id: salesforce_acc_id,
          VAT_number__c: vat_number,
          Are_you_VAT_registered_picklist__c: new_vat_registered_status
        )

        Rails.logger.info("Successfully called " \
          "change_organisation_vat_status " \
            "for salesforce account id #{salesforce_acc_id}")

      rescue Restforce::MatchesMultipleError, Restforce::UnauthorizedError,
        Restforce::EntityTooLargeError, Restforce::ResponseError => e

        if retry_number < MAX_RETRIES

          retry_number += 1

          max_sleep_seconds = Float(2 ** retry_number)

          Rails.logger.error(
            "Error in change_organisation_vat_status " \
              "for salesforce account id #{salesforce_acc_id}. #{e}"
          )

          sleep(rand(0..max_sleep_seconds))

          retry

        else
          # Raise and allow global exception handler to catch
          raise
        end

      end

    end

    # Method check Salesforce for existing Account (Organisation) records for the passed 
    # Organisation instance.
    # Firstly checks if an Account record exists with an external ID matching the organisation.id
    # If no match found, then tries to find a Account record with a matching 
    # organisation name and postcode combination.  
    # A Salesforce Id for the Account record is returned if a match is made.  Otherwise nil.
    # Calling function should handle exceptions/retries.
    #
    # @param [Organisation] organisation An instance of Organisation which is the 
    # organisation for the current user.
    #
    # @return [String] Account_salesforce_id A string representing Salesforce Id 
    #                                        for the Account record, or nil
    def find_matching_account_for_organisation(organisation)
      
      begin

        if organisation.salesforce_account_id.present?
          Rails.logger.info("FFE already has salesforce account id: "\
            "#{organisation.salesforce_account_id}, for organisation: #{organisation.id} ")  
          return organisation.salesforce_account_id
        end

        account_salesforce_id =  @client.find(
          'Account',
          organisation.id,
          'Account_External_ID__c'
        ).Id

      rescue Restforce::NotFoundError
        Rails.logger.info("Unable to find account with external id #{organisation.id} " \
          "will attempt to find account using a name and postcode match")  
      end
      
      unless account_salesforce_id 
        
        # Ruby unusual in its approach to escaping.  This is the regex approach other devs adopt: 
        # https://github.com/restforce/restforce/issues/314
        escaped_org_name = organisation.name.gsub(/[']/,"\\\\'")
    
        account_collection_from_salesforce = 
          @client.query("select Id from Account where name = '#{escaped_org_name}' and BillingPostalCode = '#{organisation.postcode}'")

        account_salesforce_id = account_collection_from_salesforce&.first&.Id

      end

      Rails.logger.info("Unable to find account with matching name and postcode for "\
        "organisation id #{organisation.id}") if account_salesforce_id.nil?
      
      account_salesforce_id

    end

    private

    # Upserts to an Account record in Salesforce using the organisation.id
    # Calling function should handle exceptions/retries
    #
    # Upsert org types when a brand new org.
    #
    # @param [Organisation] organisation An instance of a Organisation object
    #
    # @return [String] salesforce_account_id A Salesforce Account Id for the Organisation
    def upsert_account_by_organisation_id(organisation)

      @client.upsert!(
        'Account',
        'Account_External_ID__c', 
        Name: organisation.name,
        Account_External_ID__c: organisation.id,
        BillingStreet: [organisation.line1, organisation.line2, organisation.line3].compact.join(', '),
        BillingCity: organisation.townCity,
        BillingState: organisation.county,
        BillingPostalCode: organisation.postcode,
        Company_Number__c: organisation.company_number,
        Charity_Number__c: organisation.charity_number,
        Organisation_Type__c: get_organisation_type_for_salesforce(organisation),
        Are_you_VAT_registered_picklist__c: translate_vat_registered_for_salesforce(organisation.vat_registered),
        VAT_number__c: organisation.vat_number,
        Number_Of_Board_members_or_Trustees__c: organisation.board_members_or_trustees,
        organisation_description__c: organisation.description,
        Communities_that_org_serves__c: organisation.communities_that_org_serve,
        leadership_self_identify__c: organissation.leadership_self_identity,
        NumberOfEmployees: organisation.number_of_employees,
        Number_of_volunteers__c: organisation.number_of_volunteers,
        Volunteer_work_description__c: organisation.nolunteer_work_description
      )
    end

    
    # Upserts to an Account record in Salesforce using the salesforce Account Id
    # Calling function should handle exceptions/retries
    #
    # Do not upsert org type. To preserve any existing Salesforce org type.
    # At some point consider where we should upload anything to Salesforce when we
    # know the account id.  As FFE has no method to update org - whereas SF does.
    #
    # @param [Organisation] organisation An instance of a Organisation object
    # @param [String] salesforce_account_id A salesforce Account Id 
    #                                       for the User's organisation
    #
    # @return [String] salesforce_account_id A Salesforce Account Id for the Organisation
    def upsert_account_by_salesforce_id(organisation, salesforce_account_id)
      @client.upsert!(
        'Account',
        'Id', 
        Id: salesforce_account_id,
        Name: organisation.name,
        Account_External_ID__c: organisation.id,
        BillingStreet: [organisation.line1, organisation.line2, organisation.line3].compact.join(', '),
        BillingCity: organisation.townCity,
        BillingState: organisation.county,
        BillingPostalCode: organisation.postcode,
        Company_Number__c: organisation.company_number,
        Charity_Number__c: organisation.charity_number,
        Organisation_Type__c: get_organisation_type_for_salesforce(organisation),
        Are_you_VAT_registered_picklist__c: translate_vat_registered_for_salesforce(organisation.vat_registered),
        VAT_number__c: organisation.vat_number,
        Number_Of_Board_members_or_Trustees__c: organisation.board_members_or_trustees,
        organisation_description__c: organisation.description,
        Communities_that_org_serves__c: organisation.communities_that_org_serve,
        leadership_self_identify__c: organissation.leadership_self_identity,
        NumberOfEmployees: organisation.number_of_employees,
        Number_of_volunteers__c: organisation.number_of_volunteers,
        Volunteer_work_description__c: organisation.nolunteer_work_description
      )
    end

  end

end
