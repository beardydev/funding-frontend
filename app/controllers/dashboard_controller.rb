  # Controller for the service dashboard page
class DashboardController < ApplicationController
  before_action :authenticate_user!
  include DashboardHelper
  include UserHelper

  def show

    if user_details_complete(current_user)

      @salesforce_api_instance = get_salesforce_api_instance()

      gon.push({ tracking_url_path: '/project-dashboard' })

      @projects = current_user.projects

      # A user may not have an associated organisation at this point
      if current_user.organisations.any?

        @funding_applications = current_user.organisations.first.funding_applications

        if @funding_applications.present?

          # For these hashes, a FundingApplication will be key
          # A boolean on whether payment can start will be value
          @gp_open_smalls = []
          @gp_open_mediums = []
          @legally_agreed_smalls = []
          @legally_agreed_mediums = []
          @large_applications = []
          @migrated_large_delivery_grants_for_payment = []
          @migrated_medium_over_100k = []

          @funding_applications.each do |funding_application|

            @gp_open_smalls.push(funding_application) \
              if funding_application.project.present? && \
                !awarded(funding_application, @salesforce_api_instance)

            @gp_open_mediums.push(funding_application) \
              if funding_application.open_medium.present? && \
                !awarded(funding_application, @salesforce_api_instance)

            @legally_agreed_smalls.push(funding_application) \
              if funding_application.project.present? && \
                awarded(funding_application, @salesforce_api_instance)

            @legally_agreed_mediums.push(funding_application) \
            if funding_application.open_medium.present? && \
              awarded(funding_application, @salesforce_api_instance)

            @migrated_medium_over_100k.push(funding_application) if
              funding_application&.migrated_medium_over_100k?

            @migrated_large_delivery_grants_for_payment.push(
              funding_application
            ) if funding_application.migrated_large_delivery? &&
              funding_application.payment_can_start?

          end

        end

        @pre_applications = current_user.organisations.first.pre_applications

        @pa_project_enquiry_presence = get_pa_project_enquiry_presence(@pre_applications)
        @pa_expression_of_interest_presence = get_pa_expression_of_interest_presence(@pre_applications)
        
        @large_applications = get_large_salesforce_applications(@salesforce_api_instance, current_user.email)

      end

    else

      redirect_to(:user_details)

    end

  end

  # Early users of the service may not have an organisation linked to their
  # user account. Because of this, we need to check for an organisation and
  # create one if none is present. We also check for the mandatory
  # organisation details to be complete before we can allow a user to
  # create a new application.
  def orchestrate_dashboard_journey

    create_organisation_if_none_exists(current_user)

    redirect_based_on_organisation_completeness(current_user.organisations.first)

  end

  private

  # Determines whether a pa_project_enquiry object association
  # exists within a collection of PreApplication objects
  #
  # @param [ActiveRecord::Collection] pre_applications A collection of pre_applications
  def get_pa_project_enquiry_presence(pre_applications)

    presence = false

    pre_applications.each do |pa|
      if pa.pa_project_enquiry.present?
        presence = true
        break
      end
    end

    presence

  end

  # Determines whether a pa_expression_of_interest object association
  # exists within a collection of PreApplication objects
  #
  # @param [ActiveRecord::Collection] pre_applications A collection of pre_applications
  def get_pa_expression_of_interest_presence(pre_applications)

    presence = false

    pre_applications.each do |pa|
      if pa.pa_expression_of_interest.present?
        presence = true
        break
      end
    end

    presence

  end

  # Checks for the presence of an organisation associated to a user
  # and creates one if none exists
  #
  # @param [User] user An instance of User
  def create_organisation_if_none_exists(user)

    # rubocop:disable Style/GuardClause
    unless user.organisations.any?

      logger.info "No organisation found for user ID: #{user.id}"

      create_organisation(user)

    end
    # rubocop:enable Style/GuardClause

  end

  # Creates an organisation and links this to the current_user
  #
  # @param [User] user An instance of User
  def create_organisation(user)

    user.organisations.create

    logger.info "Successfully created organisation ID: #{user.organisations.first.id}"

  end

  # Redirects the user based on the completeness of their associated organisation
  # If complete, we redirect to new_application_path, otherwise if an organisation
  # is missing mandatory details, we redirect to the first page of the organisation
  # section of the service
  #
  # @param [Organisation] organisation An instance of Organisation
  def redirect_based_on_organisation_completeness(organisation)

    if helpers.complete_organisation_details?(organisation)
      logger.info "Organisation details complete for #{organisation.id}"

      redirect_to :start_an_application
    else

      logger.info "Organisation details not complete for #{organisation.id}"

      if Flipper.enabled?(:import_existing_account_enabled)
        redirect_to postcode_path 'organisation', organisation.id
      else
        redirect_to organisation_type_path(organisation.id)
      end

    end

  end

  # View is running a loop at this point and provides a hash.
  # This function determines which journey the large application is
  # ready to start.  Either a PtS or payments path is returned.
  #
  # If no suitable journey can be identified, nil is returned
  # and the calling view will not render a link.
  #
  # If no funding applcation is found, and error page is shown.
  #
  # @param [Hash] large_hash of restforce data about a large project
  # @return [String] For a link to a journey. Or nil if no suitable journey
  #
  def get_large_link(large_hash)

    # Return path to arrears payment if appropriate for this large project
    if legal_agreement_in_place?(
      large_hash[:salesforce_info][:Id],
      @salesforce_api_instance)

      funding_application = get_large_funding_application(
        large_hash[:salesforce_info][:Id],
        large_hash[:salesforce_info][:AccountId],
        DateTime.parse(large_hash[:salesforce_info][:Submission_Date_Time__c]),
        @salesforce_api_instance
      )

      if funding_application.present?

        return get_large_payments_path(funding_application)

      else

        # Problem getting funding application, return path to an error page
        Rails.logger.error("No funding application for Large project " \
          "#{large_hash[:salesforce_info][:Id]}")

        return problem_with_project_path

      end

    else # not ready for arrears payment. Return path to PtS if appropriate

      return get_pts_path(large_hash)

    end

  end
  helper_method :get_large_link


  # @param [case_id] String Salesforce reference for a Project record
  # @return [get_project_title_with_sf_connection] String A project title
  def get_project_title(case_id)

    @salesforce_api_instance = get_salesforce_api_instance()
    get_project_title_with_sf_connection(@salesforce_api_instance, case_id)

  end
  helper_method :get_project_title

  # Given a large FundingApplication, this function
  # returns a path suitable for processing a payment
  # for that application.
  #
  # It identifies the correct path from the award_type.
  # Later this may be enhanced to consider earlier payments.
  #
  # It also considers flipper gates
  #
  # @param [FundApplication] funding_application
  # @return [String] path A path to a payment journey
  #                                      nil if no valid path
  def get_large_payments_path(funding_application)

    if funding_application.dev_to_100k? && \
      Flipper.enabled?(:dev_to_100k_1st_payment)

      Rails.logger.info("Large project " \
          "#{funding_application.salesforce_case_id} " \
            "can start non-arrears payment journey")

      return funding_application_tasks_path(
        application_id: funding_application.id
      )

    elsif (funding_application.dev_over_100k? || \
      funding_application.del_250k_to_5mm? || 
        funding_application.migrated_large_delivery?) && \
          Flipper.enabled?(:large_arrears_progress_spend)

      Rails.logger.info("Large project " \
        "#{funding_application.salesforce_case_id} " \
          "can start arrears journey")

      return funding_application_progress_and_spend_start_path(
        application_id: funding_application.id
      )

    else

      # Nothing appropriate found, return nil instead of a path to a journey
      Rails.logger.error("No suitable payment journey found for Large " \
        "project #{funding_application.salesforce_case_id} in " \
          "get_large_link. Either the flipper gate is off, " \
            "or the award_type incorrect.")

      return nil

    end

  end
  helper_method :get_large_payments_path

  # Given a large hash, this function
  # returns a path suitable for processing a permission to start
  # for that application.
  #
  # It returns the path if the flipper gate is on and if the
  # permission has not already been completed.
  #
  # @param [Hash] large_hash of restforce data about a large project
  # @return [String] path A path to a permission to start journey
  #                                             nil if no valid path
  def get_pts_path(large_hash)

    project =
    SfxPtsPayment.find_by(
      salesforce_case_id: large_hash[:salesforce_info][:Id]
    )

    if Flipper.enabled?(:permission_to_start_enabled) && \
      project&.submitted_on.blank?

      Rails.logger.info("Large project " \
        "#{large_hash[:salesforce_info][:Id]} " \
          "can start PtS journey")

      return sfx_pts_payment_permission_to_start_path(
        salesforce_case_id: large_hash[:salesforce_info][:Id]
      )

    else # not ready for PtS journey.

      # Nothing appropriate found, return nil instead of a path to a journey
      Rails.logger.error("No suitable permission to start path found for " \
        "Large project #{large_hash[:salesforce_info][:Id]} in get_pts_path.")

      return nil

    end

  end

end
