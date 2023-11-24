module OrganisationSalesforceApi

  class OrganisationSalesforceApiClient
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
      
      if organisation.governing_document_file.attached?
          create_multiple_files_in_salesforce(
            organisation.governing_document_file,
            'Governing Document',
            salesforce_account_id
          )
      end

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
          "Company_Number__c, Charity_Number__c, Organisation_s_Main_Purpose_Activities__c, "\
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

    # Method to upsert a ContentVersion in Salesforce for a governing document
    #
    # @param [ActiveStorageBlob] file The governing document file to upload
    # @param [String] type The type of file to upload (e.g. 'governing document')
    # @param [String] salesforce_reference The Salesforce Case reference
    #                                              to link this upload to
    # @param [String] description A description of the file being uploaded
    def create_file_in_salesforce(
      file,
      type,
      salesforce_reference,
      description = nil
    )

      Rails.logger.info("Creating #{type} file in Salesforce")

      Rails.logger.debug('Using ApplicationHelper to create file')

      insert_salesforce_attachment(
        @client,
        file,
        type,
        salesforce_reference,
        description
      )

      Rails.logger.debug('Finished using ApplicationHelper to create file')

      Rails.logger.info("Finished creating #{type} file in Salesforce")

    end

    # Method to orchestrate creation of multiple files in Salesforce
    #
    # @param [ActiveStorageBlob] files The files to upload
    # @param [String] type The type of file to upload (e.g. 'accounts')
    # @param [String] salesforce_project_reference The Salesforce Case reference
    #                                              to link an uploaded file to
    # @param [String] description A description of the file being uploaded
    def create_multiple_files_in_salesforce(
      files,
      type,
      salesforce_project_reference,
      description = nil
    )

      Rails.logger.info("Creating #{type} files in Salesforce")

      files.each_with_index do |file, i|

        create_file_in_salesforce(
          file,
          "#{type} #{i + 1}",
          salesforce_project_reference,
          description
        )

      end

      Rails.logger.info("Finished creating #{type} files in Salesforce")

    end

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
        Custom_org_type__c: organisation.custom_org_type,
        Are_you_VAT_registered_picklist__c: translate_vat_registered_for_salesforce(organisation.vat_registered),
        VAT_number__c: organisation.vat_number,
        Number_Of_Board_members_or_Trustees__c: organisation.board_members_or_trustees,
        Organisation_s_Main_Purpose_Activities__c: organisation.main_purpose_and_activities,
        Communities_that_org_serves__c:  convert_to_salesforce_leadership_and_communities(organisation.communities_that_org_serve),
        leadership_self_identify__c: convert_to_salesforce_leadership_and_communities(organisation.leadership_self_identify),
        NumberOfEmployees: organisation.number_of_employees,
        Number_of_volunteers__c: organisation.number_of_volunteers,
        Volunteer_work_description__c: organisation.volunteer_work_description
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
        Custom_org_type__c: organisation.custom_org_type,
        Are_you_VAT_registered_picklist__c: translate_vat_registered_for_salesforce(organisation.vat_registered),
        VAT_number__c: organisation.vat_number,
        Number_Of_Board_members_or_Trustees__c: organisation.board_members_or_trustees,
        Organisation_s_Main_Purpose_Activities__c: organisation.main_purpose_and_activities,
        Communities_that_org_serves__c:  convert_to_salesforce_leadership_and_communities(organisation.communities_that_org_serve),
        leadership_self_identify__c: convert_to_salesforce_leadership_and_communities(organisation.leadership_self_identify),
        NumberOfEmployees: organisation.number_of_employees,
        Number_of_volunteers__c: organisation.number_of_volunteers,
        Volunteer_work_description__c: organisation.volunteer_work_description
      )
    end


    private 


    # Rails stores leadership_and_communities values as a comma delimited set of strings.
    # Salesforce requires these to be a semi-colon delimited string.
    #
    # @param [Array] an array of leadership_and_communities strings for an Organisation
    #
    # @return [Array] A re-mapped array of leadership_and_communities strings formatted for Salesforce
    def convert_to_salesforce_leadership_and_communities(leadership_communities_values)

      unless leadership_communities_values.nil?
        salesforce_leadership_and_communities_array = leadership_communities_values.map { |value| convert_leadership_and_communities([value]) }
        return salesforce_leadership_and_communities_array.join(';')
      end
   
      return nil
      
    end


  # Method to convert salesforce leadership_and_communities values to FFE type
  # aligning FFE with any salesforce changes.
  #
  # @param [String] leadership_and_communities values A string containing a collection of
  #                              leadership_and_communities values, in the salesforce format.
  #
  # @return [Array<string> ] leadership_and_communities_list String array of FFE mission/objectives  
  #                                         to add against organisation. 
  def convert_leadership_and_communities(leadership_communities_values)

    leadership_and_communities_list = []

    if leadership_communities_values.present?

      leadership_communities_values.each do | value |
        case value
        when 'communities_experiencing_ethnic_or_racial_inequity_discrimination_inequality'
          leadership_and_communities_list.append('Communities experiencing ethnic or racial inequity, discrimination or inequality')
        when 'faith_communities'
          leadership_and_communities_list.append('Faith communities')
        when 'people_who_have_migrated_and_or_have_experience_of_the_immigration_system'
          leadership_and_communities_list.append('People who have migrated and or have experience of the immigration system')
        when 'deaf_disabled_blind_partially_sighted_and_or_neurodivergent_people'
          leadership_and_communities_list.append('dDeaf, Disabled, Blind, Partially Sighted and or Neurodivergent People')
        when 'older_people_65_and_over'
          leadership_and_communities_list.append('Older people 65 and over')
        when 'young_people_led'
          leadership_and_communities_list.append('Younger people under 25')
        when 'women_and_girls'
          leadership_and_communities_list.append('Women and girls')
        when 'lgbt_plus_led'
          leadership_and_communities_list.append('LGBTQplus people')
        when 'people_who_are_educationally_or_economically_disadvantaged'
          leadership_and_communities_list.append('People who are educationally or economically disadvantaged')
        when 'specific_groups_that_are_not_included_already'
          leadership_and_communities_list.append('Specific groups that are not included already')
        when 'None of the above'
          leadership_and_communities_list.append('None of the above')
        else
          nil
        end
      end

    end
    leadership_and_communities_list
  end

    # Uses an organisation's org_type to create the salesforce equivalent
    # Use 'Other' in event of non match to so applicant not impacted.
    #
    # @param [Organisation] instance of Organisation
    #
    # @return [String] A salesforce version of an org type
    def get_organisation_type_for_salesforce(organisation)

      formatted_org_type_value = case organisation.org_type
      when 'registered_charity'
        'Registered charity'
      when 'local_authority'
        'Local authority'
      when 'registered_company', 'community_interest_company'
        'Registered company or Community Interest Company (CIC)'
      when 'faith_based_organisation', 'church_organisation'
        'Faith based or church organisation'
      when 'community_group', 'voluntary_group'
        'Community of Voluntary group' # Typo is present in Salesforce API name
      when 'individual_private_owner_of_heritage'
        'Private owner of heritage'
      when 'other_public_sector_organisation'
        'Other public sector organisation'
      when 'other'
        'Other organisation type'
      when 'other_constituted_unincorporated_club_or_society'
        'Other constituted group, unincorporated club or society'
      when'trust'
        'Trust'
      when 'cooperative_industrial_provident_registered_society'
        'Co-operative Society, Industrial and Provident Society, Registered Societies'
      when 'partnership_or_llp'
        'Partnership or Limited Liability Partnership LLP'
      when 'charitable_incorporated_organisation'
        'Charitable Incorporated Organisation CIO'
      when'public_or_private_company'
        'Public Private Company'
      else
        'Unknown organisation type'
      end
    end

    
    # Method to translate vat_registered attribute into it's
    # Salesforce equivalent
    #
    # @param [Boolean] vat_registered A Boolean representation of
    #                                 whether an org is VAT registred
    # @return [String] A string representation that maps to the correct
    #                  picklist value in Salesforce
    def translate_vat_registered_for_salesforce(vat_registered)

      vat_registered_salesforce = case vat_registered
      when true
        'Yes'
      when false
        'No'
      else
        'N/A'
      end

    end


  end

end
