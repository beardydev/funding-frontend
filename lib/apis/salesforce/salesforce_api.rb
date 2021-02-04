module SalesforceApi

  # Class to allow interaction with Salesforce via a Restforce client
  class SalesforceApiClient

    # Overrides the .new() method, allowing us to initialise a Restforce client
    # when the SalesforceApiClient class is instantiated
    def initialize

      initialise_client

    end

    # Method to retrieve details needed during a payment request journey
    #
    # @example
    #
    #   instantiated_object.get_payment_related_details('6665bd00-db85-4f68-95e3-16f9ca99ba40')
    #
    # @param [String] id A project's UUID
    #
    # @return [Hash] A Hash, currently containing only the amount awarded to the project
    #                and the percentage of the total costs that the organisation have agreed
    #                to award
    def get_payment_related_details(id)

      Rails.logger.info("Retrieving payment-related details for project ID: #{id}")

      begin

        # Equivalent of "SELECT Grant_Award__c, Grant_Percentage__c FROM Case WHERE ApplicationId__c = '#{id}'"
        restforce_response = @client.select('Case', id, ['Grant_Award__c', 'Grant_Percentage__c'], 'ApplicationId__c')

      rescue Restforce::NotFoundError => e

        Rails.logger.error(
          "Exception occured when retrieving payment-related details for project ID: #{id}:" \
          " - no Case found for #{id} (#{e})"
        )

        # Raise and allow global exception handler to catch
        raise

      rescue Restforce::MatchesMultipleError, Restforce::UnauthorizedError,
             Restforce::EntityTooLargeError, Restforce::ResponseError => e

        Rails.logger.error("Exception occured when retrieving payment-related details for project ID: #{id}: (#{e})")

        # Raise and allow global exception handler to catch
        raise

      end

      Rails.logger.info("Finished retrieving payment-related details for project ID: #{id}")

      {
        'grant_award': restforce_response.Grant_Award__c,
        'grant_percentage': restforce_response.Grant_Percentage__c
      }

    end

    private

    # Method to initialise a new Restforce client, called as part of object instantiation
    def initialise_client

      Rails.logger.info('Initialising Salesforce client')

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

    end

  end

end
