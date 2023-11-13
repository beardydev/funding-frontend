Rails.application.reloader.to_prepare do

  SALESFORCE_URL_BASE =
    if Rails.env.test? || ENV["SKIP_SALESFORCE_INIT"] == "true"
      ""
    else
      SalesforceApi::SalesforceApiClient.new.get_salesforce_url
    end
end
