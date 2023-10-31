module OrganisationSalesforceApi

  class OrganisationSalesforceApi
    include SalesforceApiHelper

    # Overrides the .new() method, allowing us to initialise a Restforce client
    # when the class is instantiated
    def initialize

      initialise_client

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
          "Company_Number__c, Charity_Number__c, "\
            "Organisation_Type__c, Organisation_s_Mission_and_Objectives__c, " \
              "Are_you_VAT_registered_picklist__c, VAT_number__c, "\
                "Number_Of_Board_members_or_Trustees__c "\
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
              "for payment form id: #{salesforce_payment_request_id}. #{e}"
          )

          sleep(rand(0..max_sleep_seconds))

          retry

        else
          # Raise and allow global exception handler to catch
          raise
        end

      end

    end

  end

end
