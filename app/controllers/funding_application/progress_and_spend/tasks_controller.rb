class FundingApplication::ProgressAndSpend::TasksController < ApplicationController
  include FundingApplicationContext
  include Enums::ArrearsJourneyStatus
  
    def show()

      @complete_progress_tasks =  \
        @funding_application.arrears_journey_tracker.\
          progress_update_id.present?
      
      @complete_payment_tasks = \
        @funding_application.arrears_journey_tracker.\
          payment_request_id.present?

      if @complete_progress_tasks
        @how_project_going_status = journey_status_string(progress_update
          .answers_json['journey_status']['how_project_going'])
        @approved_purposes_status = journey_status_string(progress_update
          .answers_json['journey_status']['approved_purposes'])
      end

      if @complete_payment_tasks
        @payment_request_status = journey_status_string(payment_request
          .answers_json['arrears_journey']['status'])

        @bank_details_status = journey_status_string(payment_request
          .answers_json['bank_details_journey']['status'])
      end

    end
  
    def update()
  
    end

    private

    def progress_update
      @funding_application.arrears_journey_tracker.progress_update
    end

    def payment_request
      @funding_application.arrears_journey_tracker.payment_request
    end

    def get_tag_colour(status) 
      case status
      when :in_progress
        colour = 'blue'
      when :completed
        colour = 'grey'
      else
        colour = ''
      end

      colour
    end

    helper_method :get_tag_colour
  end
