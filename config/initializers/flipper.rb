if ENV["SKIP_FLIPPER_INIT"] != "true" && ActiveRecord::Base.connection.table_exists?(:flipper_features)
  Flipper.configure do |config|
    config.default do
      adapter = Flipper::Adapters::ActiveRecord.new
      Flipper.new(adapter)
    end
    # Flipper gates toggle app features on and off. Adding the flippers
    # here creates a row in flipper_features.
    # To control toggles - see README
    Flipper[:registration_enabled].add
    Flipper[:new_applications_enabled].add
    Flipper[:grant_programme_sff_small].add
    Flipper[:project_enquiries_enabled].add
    Flipper[:expressions_of_interest_enabled].add
    Flipper[:payment_requests_enabled].add
    Flipper[:grant_programme_sff_medium].add
    Flipper[:permission_to_start_enabled].add
    Flipper[:progress_and_spend].add
    Flipper[:large_arrears_progress_spend].add
    Flipper[:dev_to_100k_1st_payment].add
    Flipper[:m1_40_payment].add
    Flipper[:m1_40_payment_release].add
    Flipper[:dev_40_payment].add
    Flipper[:dev_40_payment_release].add
    Flipper[:import_enabled].add
    Flipper[:import_existing_contact_enabled].add
    Flipper[:import_existing_account_enabled].add
    Flipper[:disable_ffe].add
  end
end
