module PaymentRequestSalesforceApi

  # Class to allow interaction with Salesforce via a Restforce client
  class PaymentRequestSalesforceApiClient
    include SalesforceApiHelper

    # Overrides the .new() method, allowing us to initialise a Restforce client
    # when the class is instantiated
    def initialize

      initialise_client

    end

    # Method to get an aggregated list of cost headings from salesforce.
    #
    # @param [string] case_id Salesforce reference for a case
    # @param [string] record_type_id Salesforce id for a project cost
    #                                 record type.
    # @return [Array] result_array.  Array of cost headings
    def salesforce_cost_headings(case_id, record_type_id)

      Rails.logger.info("Retrieving salesforce cost headings" \
        "for salesforce case id: #{case_id}")

      restforce_response = []
      result_array = []

      query_string = "SELECT Cost_heading__c " \
        "FROM Project_Cost__c WHERE Case__c = " \
          "'#{case_id}' " \
            "and RecordTypeId = '#{record_type_id}' GROUP BY Cost_heading__c "

      restforce_response = run_salesforce_query(query_string,
        "salesforce_cost_headings", case_id) \
          if query_string.present?

      restforce_response.each do |record|
        result_array.push(record.Cost_heading__c)
      end

      result_array

    end

    # Calls salesforce api helper to get the record type id
    # for a medium grant record type of a project cost record
    # @return [String] a record type id
    def record_type_id_medium_grant_cost

      get_salesforce_record_type_id(
      'Medium_Grants',
      'Project_Cost__c'
      )
      
    end

     # Method responsible for upserting any progress update data models
    # to their counter parts in SF
    #
    # @param [FundingApplication] funding_application An instance of
    #                                                 FundingApplication
    # @param [String] string id for SF payemnt request form to upsert against
    def upsert_payment_request(
      funding_application, 
      salesforce_payment_request_id)

      retry_number = 0

      payment_request = funding_application
        .arrears_journey_tracker.payment_request

      Rails.logger.info("Upserting payment_request data " \
        "to payment request with ID: #{payment_request.id}")

      begin

        # Attach high spends
        payment_request.high_spend.each do | high_spend | 
          @client.upsert!(
            'Spending_Costs__c',
            'External_Id__c',
            External_Id__c: high_spend.id,
            Forms__c: salesforce_payment_request_id,
            Cost_Heading__c: high_spend.cost_heading,
            Amount__c: high_spend.amount , 
            VAT__c: high_spend.vat_amount,
            Date_of_spend__c: 
              high_spend.date_of_spend&.strftime("%Y-%m-%d"),
            Description__c: high_spend.description,
            Spend_level__c: "Spend over £#{high_spend.spend_threshold}"
          )

          upsert_document_to_salesforce(
            high_spend.evidence_of_spend_file.attachment, 
            "High spend #{high_spend.cost_heading} evidence - #{high_spend
              .evidence_of_spend_file_blob
                .filename}",
            salesforce_payment_request_id
          )
        end

        # Attach low spends
        payment_request.low_spend.each do | low_spend | 
          @client.upsert!(
            'Spending_Costs__c',
            'External_Id__c',
            External_Id__c: low_spend.id,
            Forms__c: salesforce_payment_request_id,
            Cost_Heading__c: low_spend.cost_heading,
            Amount__c: (low_spend.total_amount - low_spend.vat_amount), 
            VAT__c: low_spend.vat_amount,
            Spend_level__c: "Spend less than £#{low_spend.spend_threshold}"
          )

        end

        # Upload table of spend
        upsert_document_to_salesforce(
          payment_request.table_of_spend_file.attachment, 
          "Spend table - #{payment_request
            .table_of_spend_file
              .filename}",
          salesforce_payment_request_id
        )

        Rails.logger.info("Successfuly upserted payment request data with " \
          "ID: #{payment_request.id}")

      rescue Restforce::MatchesMultipleError, Restforce::UnauthorizedError,
        Restforce::EntityTooLargeError, Restforce::ResponseError => e

        if retry_number < MAX_RETRIES

          retry_number += 1

          max_sleep_seconds = Float(2 ** retry_number)

          Rails.logger.error(
            "Error upserting payment request with ID: #{payment_request.id}. #{e}"
          )

          sleep(rand(0..max_sleep_seconds))

          retry

        else
          # Raise and allow global exception handler to catch
          raise
        end

      end

    end

    # Method to see if an account already has a bank account associated.
    #
    # @param [String] salesforce_account_id Salesforce reference for an org
    # @return [Boolean] (restforce_response.size > 0) 
    #                        True if the org has a bank account in Salesforce
    def org_has_bank_account_in_salesforce(salesforce_account_id)

      Rails.logger.info("Checking for bank account for " \
        "for salesforce account id: #{salesforce_account_id}")

      query_string = "SELECT COUNT() " \
        "FROM Bank_Account__c where Organisation__c = " \
          "'#{salesforce_account_id}'"

      restforce_response = run_salesforce_query(query_string,
        "org_has_bank_account_in_salesforce", salesforce_account_id) \
          if query_string.present?

      restforce_response.size > 0

    end

    private

    # Method to upsert a payment form files in Salesforce for a Permission to Start application
    #
    # @param [ActiveStorageBlob] file attachment to upload
    # @param [String] type The type of file to upload (e.g. 'photo evidence')
    # @param [String] salesforce_reference The Salesforce Form reference
    #                                              to link this upload to
    # @param [String] description A description of the file being uploaded
    def upsert_document_to_salesforce(
      file,
      type,
      salesforce_reference,
      description = nil
    )

      Rails.logger.info("Creating #{type} file in Salesforce")

      UploadDocumentJob.perform_later(
        file,
        type,
        salesforce_reference,
        description
      )

      Rails.logger.info("Finished creating #{type} file in Salesforce")

    end

  end


end
