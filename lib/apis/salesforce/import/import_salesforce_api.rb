module ImportSalesforceApi

  class ImportSalesforceApiClient

    MAX_RETRIES = 3

    # Overrides the .new() method, allowing us to initialise a Restforce client
    # when the AgreementSalesforceApi class is instantiated
    def initialize

      initialise_client

    end

    # Method to retrieve imported project information.
    #
    # @param [case_id] String A Case Id reference known to Salesforce
    # @return [restforce_response] RestforceResponse A response object
    # containing the details required to import a project.
    #       
    def retrieve_imported_project_info(case_id)

      begin
        restforce_response = run_salesforce_select(
          'Case',
          case_id,
          'Id',
          [
            'ContactEmail',
            'ContactId',
            'AccountId',
            'Account.Name',
            'Account.BillingStreet',
            'Account.BillingCity',
            'Account.BillingState',
            'Account.BillingPostalCode',
            'Project_Reference_Number__c',
            'Project_Title__c',
            'Project_Street__c',
            'Project_City__c',
            'Project_County__c',
            'Project_Post_Code__c',
            'Owner.name',
            'Permission_to_start_date__c',
            'Submission_Date_Migrated__c',
            'recordType.DeveloperName'
          ],
          'retrieve_imported_project_info',
          case_id
        )

        restforce_response

      rescue Restforce::ErrorCode::FieldIntegrityException => e
        Rails.logger.error(e)

        restforce_response = nil
      end

    end

    # Method to retrieve existing contact information from SF by Contact Id.
    #
    # @param [salesforce_contact_id] String A SF Contact Id
    # @return [restforce_response] RestforceResponse A response object
    #                   containing the existing contact details if found.
    #    
    def retrieve_existing_salesforce_contact(salesforce_contact_id)

      restforce_response = run_salesforce_select(
        'Contact',
        salesforce_contact_id,
        'Id',
        [
          'FirstName',
          'MiddleName',
          'LastName',
          'Email',
          'Birthdate',
          'Language_Preference__c',
          'Phone',
          'MobilePhone',
          'MailingAddress',
          'Agrees_To_User_Research__c',
          'Other_communication_needs_for_contact__c'
        ],
        'retrieve_existing_salesforce_contact',
        salesforce_contact_id
      )

      restforce_response

    end

   
    # Method to retrieve existing salesforce contact details with 
    # an email address that matches a passed email.
    #
    # NHMF contacts should NOT be considered a duplicate.
    # This is because the digital experience portals for large grants
    # and NHMF applications each require their own distinct user with
    # a role.  And Salesforce works better with one contact per user.
    #
    # @param [email] String an email
    # @param [current_user_id] String user.id to log
    # @return [restforce_response] <Restforce::SObject>
    #   Restforce Response object containing matching SF contact details.
    def retrieve_existing_sf_contact_info_by_email(email, current_user_id)

      # allows emails to contain apostrophes
      escaped_email = email.gsub(/[']/,"\\\\'")

      query = "SELECT Id, LastName, FirstName, MiddleName, Email, " \
        "Birthdate, Language_Preference__c, Phone, MobilePhone, " \
          "MailingAddress, LastModifiedDate, Agrees_To_User_Research__c, " \
            "Other_communication_needs_for_contact__c " \
              "FROM Contact " \
                "WHERE Email = '#{escaped_email}' " \
                  "AND Id NOT IN " \
                    "(SELECT ContactId FROM User where email = '#{escaped_email}' " \
                      "AND profile.name = 'Applicant Community User') "

      restforce_response = run_salesforce_query(
        query,
        'retrieve_existing_sf_contact_info_by_email',
        current_user_id
      )

      log_safe_info = []
      restforce_response.each do |contact|
        log_safe_info.push(contact.Id)
      end

      Rails.logger.info("The following (non NHMF) Salesforce contacts were " \
        "found with an email that matches Funding Frontend User id: " \
          "#{current_user_id}: #{log_safe_info}")

      restforce_response

    end

    # Method to retrieve existing salesforce organisation account details using
    # the organisation name and postcode.
    #
    # First result is the one most recently modified.
    #
    # @param [name] String organisation name 
    # @param [postcode] String organisation postcode
    # @param [org_id] String organisation Id to log 
    # @return [restforce_response] <Restforce::SObject> Restforce Response
    #              object containing the organisation existing account details.
    def retrieve_existing_account_info(name, postcode, org_id)
      query = "SELECT " \
      "Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, " \
        "Company_Number__c, Charity_Number__c, Id, "\
          "Organisation_Type__c, Organisation_s_Mission_and_Objectives__c, " \
            "Are_you_VAT_registered_picklist__c, VAT_number__c, "\
              "Number_Of_Board_members_or_Trustees__c "\
                "FROM Account " \
                  "where Name = '#{name}' and " \
                    "BillingPostalCode = '#{postcode}' " \
                      "order by LastModifiedDate desc"

    restforce_response = run_salesforce_query(
      query,
      'retrieve_existing_account_info',
      org_id
    )

    restforce_response
    end


    # Gets a list of projects, migrated from GEMS, that have been marked
    # for reconnetion to FFE
    # @return [get_projects_selected_for_reconnection] Restforce::Collection
    
    def get_projects_selected_for_reconnection
      query = "SELECT Owner.Name, Project_Title__c, " \
        "Region__c, Project_Reference_Number__c " \
          "FROM Case where Export_to_IMS_Portal__c = true "

      restforce_response = run_salesforce_query(
        query,
        'get_projects_selected_for_reconnection',
         nil
      )

    end

    # Consider moving to some kind of helper.  Or write methods in an
    # abstract class that each of these classes inherit from.
    private

    # Method to initialise a new Restforce client, called as part of object
    # instantiation
    def initialise_client

      Rails.logger.info('Initialising Salesforce client')

      retry_number = 0
      
      begin

        @client = Restforce.new(
          username: Rails.configuration.x.salesforce.username,
          password: Rails.configuration.x.salesforce.password,
          security_token: Rails.configuration.x.salesforce.security_token,
          client_id: Rails.configuration.x.salesforce.client_id,
          client_secret: Rails.configuration.x.salesforce.client_secret,
          host: Rails.configuration.x.salesforce.host,
          api_version: '47.0'
        )

        Rails.logger.info('Finished initialising Salesforce client')

      rescue Timeout::Error, Faraday::ClientError => e

        if retry_number < MAX_RETRIES

          retry_number += 1

          max_sleep_seconds = Float(2 ** retry_number)

          Rails.logger.info(
            "Will attempt to initialise_client again, retry number #{retry_number} " \
            "after a sleeping for up to #{max_sleep_seconds} seconds"
          )

          sleep(rand(0..max_sleep_seconds))

          retry

        else

          raise

        end

      end

    end
    
    # Method to run a salesforce query with MAX_RETRIES.
    #
    # @param [query_string] String The query to be run
    # @param [calling_function_name] String Name of calling function
    # @param [log_safe_id] String A unique id. But no personal info.
    # @return [<Restforce::SObject>] result&first.  A Restforce object
    #                                               with query results
    def run_salesforce_query(query_string, calling_function_name,
      log_safe_id)
      
      retry_number = 0

      begin

        restforce_response = @client.query(query_string)

        restforce_response

      rescue Restforce::MatchesMultipleError, Restforce::UnauthorizedError,
              Restforce::EntityTooLargeError, Restforce::ResponseError => e

        Rails.logger.error(
          "Exception occured in #{calling_function_name}, with log_safe_id: " \
            "#{log_safe_id} (#{e})"
        )

        # Raise and allow global exception handler to catch
        raise

      rescue Timeout::Error, Faraday::ClientError => e

        if retry_number < MAX_RETRIES

          retry_number += 1

          max_sleep_seconds = Float(2 ** retry_number)

          Rails.logger.info(
            "Will attempt #{calling_function_name} with log_safe_id: " \
              "#{log_safe_id} again, retry number #{retry_number} " \
                "after a sleeping for up to #{max_sleep_seconds} seconds"
          )

          sleep rand(0..max_sleep_seconds)

          retry

        else

          raise

        end

      end

    end

    # Method to run a salesforce select with MAX_RETRIES.
    # select_field is the field we use to search against, like with a
    # where clause
    #
    # @param [object_string] String The name of the Object being selected from
    # @param [select_field_value] String The value of the select string
    # @param [select_field_name] String The name of the select string
    # @param [fields_array] Array Array of strings for the fields we want
    # @param [calling_function_name] String Name of calling function
    # @param [log_safe_id] String A unique id. But no personal info.
    # @return [<Restforce::SObject>] result&first.  A Restforce object
    #                                               with query results
    def run_salesforce_select(object_string, select_field_value,
      select_field_name, fields_array, calling_function_name, log_safe_id)

      retry_number = 0

      begin

        restforce_response =
          @client.select(
            object_string,
            select_field_value,
            fields_array,
            select_field_name
          )

        restforce_response

      rescue Restforce::NotFoundError => e

        Rails.logger.info("Nothing found by run_salesforce_select " \
          "when called from #{calling_function_name} using " \
            "#{select_field_name}. Log safe id is: #{log_safe_id}")

        restforce_response = nil

      rescue Restforce::MatchesMultipleError, Restforce::UnauthorizedError,
        Restforce::EntityTooLargeError, Restforce::ResponseError => e

        Rails.logger.error("Restforce error from run_salesforce_select, " \
          "called from #{calling_function_name} for #{select_field_name}. " \
            "Log safe id is: #{select_field_value}")

        # Raise and allow global exception handler to catch
        raise

      rescue Timeout::Error, Faraday::ClientError => e

        if retry_number < MAX_RETRIES

          retry_number += 1

          max_sleep_seconds = Float(2 ** retry_number)

          Rails.logger.info(
            "Will attempt #{calling_function_name} again, " \
            "#{select_field_name}: #{select_field_value}, " \
            "for retry number #{retry_number} " \
            "after a sleeping for up to #{max_sleep_seconds} seconds"
          )

          sleep rand(0..max_sleep_seconds)

          retry

        else

          raise

        end

      end

    end

  end 

end 
