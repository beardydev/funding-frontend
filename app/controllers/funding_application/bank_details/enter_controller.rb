class FundingApplication::BankDetails::EnterController < ApplicationController
    include FundingApplicationContext
    include ObjectErrorsLogger
    
  def show
    @funding_application.payment_details = PaymentDetails.new unless
      @funding_application.payment_details.present?
  end

  def update

      logger.info "Updating payment details for funding_application ID: #{@funding_application.id}"

      @funding_application.payment_details.validate_account_name_presence = true
      @funding_application.payment_details.validate_account_number_presence = true
      @funding_application.payment_details.validate_sort_code_presence = true

      @funding_application.payment_details.validate_account_number_format = true
      @funding_application.payment_details.validate_sort_code_format = true
      @funding_application.payment_details.validate_building_society_roll_number_format = true
      @funding_application.payment_details.validate_payment_reference_format = true
      @funding_application.payment_details.encrypt_account_name = true
      
      @funding_application.payment_details.update(payment_params)

      if @funding_application.payment_details.valid?

        logger.info "Finished updating payment details for funding_application ID: #{@funding_application.id}"

        redirect_to(:funding_application_bank_details_confirm)

      else

        logger.info('Validation failed when submitting payment details ' \
                    "for funding_application ID: #{@funding_application.id}")
        
        log_errors(@funding_application.payment_details)

        render :show

      end

  end

  def payment_params

    params.require(:payment_details).permit(
      :account_name, 
      :account_number, 
      :sort_code, 
      :building_society_roll_number, 
      :payment_reference
    )

  end

end
