# Controller class for address-related functionality. Provides the ability
# to update address details for User, Project and Organisation model
# objects.
class AddressController < ApplicationController
  include ObjectErrorsLogger
  include PostcodeLookup
  include ImportHelper
  include UserHelper
  include OrganisationHelper
  before_action :authenticate_user!, :check_and_set_model_type

  def assign_address_attributes

    assign_attributes(@model_object)

    render :show

  end

  # This method updates the address for a given model object, which could
  # be of types user, organisation or project. If of type user, then the
  # address attributes are replicated to a separate address record which is
  # then associated with the user and it's associated person record
  def update

    logger.info "Updating address for #{@type} ID: #{@model_object.id}"

    @model_object.validate_address = true

    @model_object.update(model_params)

    if @model_object.valid?

      logger.info "Finished updating address for #{@type} ID: " \
                  "#{@model_object.id}"

      if @type == 'organisation'

        if Flipper.enabled?(:import_existing_account_enabled)
          retrieved_orgs = retrieve_matching_sf_orgs(@model_object)

          if retrieved_orgs.size > 0

            if suitable_org(retrieved_orgs).present?
              redirect_to start_an_application_path
            else
              redirect_to organisation_existing_organisations_error_url(@model_object.id)
            end

          else
            redirect_to organisation_type_path(params['id'])
          end

        else
          redirect_to org_description_path(params['id'])
        end

      elsif @type == 'preapplication'

        if Flipper.enabled?(:import_existing_account_enabled)
          retrieved_orgs = retrieve_matching_sf_orgs(@model_object)

          if retrieved_orgs.size > 0

            if suitable_org(retrieved_orgs).present?

              redirect_to pre_application_project_enquiry_previous_contact_url(@pre_application.id) if
                @pre_application.pa_project_enquiry.present?

              redirect_to pre_application_expression_of_interest_previous_contact_url(@pre_application.id) if
                @pre_application.pa_expression_of_interest.present?

            else
              redirect_to organisation_existing_organisations_error_url(@model_object.id)
            end

          else

            redirect_to(
              pre_application_organisation_type_path(
                params['id'],
                @model_object.id
              )
            )

          end

        else

          redirect_to(
            pre_application_organisation_mission_path(
              pre_application_id: params['id'],
              organisation_id: @model_object.id
            )
          )
        end

      elsif @type == 'project'

        redirect_to funding_application_gp_project_description_path(@model_object.funding_application.id)

      elsif @type == 'gp-open-medium'

        redirect_to funding_application_gp_open_medium_description_path(@model_object.funding_application.id)
      
      elsif @type == 'user'

        # Caters to a situation where original applicants have no person assigned to the user.
        check_and_set_person_address(@model_object) if @model_object.person.present?
      
        # Redirect to capture the organization's name
        redirect_to organisation_organisation_name_path(organisation_id: current_user.organisations.first.id, type: 'organisation')

      end

    else

      logger.info 'Validation failed when attempting to update address for ' \
                  "#{@type} ID: #{@model_object.id}"

      log_errors(@model_object)

      render :show

    end


  end 

  private

  # Checks for a known type of model in the params.
  # If correct, then assign the model type to a @type instance variable.
  def check_and_set_model_type
    if %w[user organisation project gp-open-medium preapplication].include? params[:type]
      @type = params[:type]
      case @type
      when 'organisation'
        @model_object = Organisation.find(params[:id])
        redirect_to :root unless current_user.organisations.first&.id == @model_object&.id
      when 'project'
        @model_object = Project.find(params[:id])
        redirect_to :root unless current_user.id == @model_object&.user_id
      when 'gp-open-medium'
        @model_object = OpenMedium.find(params[:id])
        redirect_to :root unless current_user.id == @model_object&.user_id
      when 'user'
        users_organisation = UsersOrganisation.find_by(organisation_id: params[:id])
        @model_object = current_user
        redirect_to :root unless users_organisation.user_id == current_user.id
      when 'preapplication'
        # When @type is 'preapplication', we need to actually set the
        # address against the associated Organisation object
        @pre_application = PreApplication.find(params[:id])
        @model_object = Organisation.find(@pre_application.organisation_id)
        redirect_to :root unless current_user.organisations.first&.id == @model_object&.id
      end
    else
      redirect_to :root
    end
  end

  def model_params

    # Ensure that the required param is set to either the @type value,
    # or 'organisation' if @type is equal to 'preapplication'. We do
    # this to ensure that during a pre-application journey, we don't
    # require a param of 'preapplication', when we are actually dealing
    # with an organisation object
    if @type == 'preapplication'
      model_type = 'organisation'
    elsif @type == 'gp-open-medium'
      model_type = 'open_medium'
    else
      model_type = @type
    end
    # model_type = @type == 'preapplication' ? 'organisation' : @type

    params.require(model_type)
          .permit(:name, :line1, :line2, :line3,
                  :townCity, :county, :postcode)
  end

  # Provides a restforce collection.  And returns a populated
  #                         Organisation object if something suitable found
  #
  # The Restforce::Collection is ordered by LastModifiedDate desc so that
  # the first organisation is the most recent and potentially the one we
  # should populate the FFE database from.  Also suitable for reporting
  # errors to support via mails.
  #
  # Uses a collection of memory only orgs for validation and comparision.
  # If the in-memory collection contains complete information, and appropriate
  # information matches throughout the collection, then the user's org is
  # populated from all available Salesforce Account information (including
  # medium grant questions).
  # This is so that SF Account medium grant information is included in new
  # submissions to Salesforce (and not overwritten by nil).
  #
  # @param [retreived_orgs] Restforce::Collection Collection of SF Accounts
  # @return [organisation] Organisation A suitable organisation, or nil
  def suitable_org(retrieved_orgs)

    in_mem_orgs =
      convert_salesforce_account_collection_to_organisations(retrieved_orgs)

    complete = orgs_are_complete?(in_mem_orgs)
    match = orgs_match?(in_mem_orgs)

    current_user_org = current_user.organisations.first

    if complete && match

      current_user_org.salesforce_account_id = in_mem_orgs.first.salesforce_account_id
      update_existing_organisation_from_salesforce_details(current_user_org)
      update_org_with_medium_grant_questions(current_user_org)
      current_user_org.org_type = :unknown
      current_user_org.save!

      Rails.logger.info("Successfully populated organisation " \
        "#{current_user_org.id} from existing Salesforce account " \
          "#{in_mem_orgs.first.salesforce_account_id}.")

      return current_user_org

    elsif !match

      send_multiple_account_import_error_support_email(
        current_user.email,
        in_mem_orgs.first.name,
        in_mem_orgs.first.postcode
      )

      Rails.logger.info("Unsuccessfully populated organisation " \
        "#{current_user_org.id} from existing Salesforce account " \
          "#{in_mem_orgs.first.salesforce_account_id}. " \
            "Multiple orgs found that did not match.")

    elsif !complete

      send_incomplete_account_import_error_support_email(
        current_user.email,
        in_mem_orgs.first
      )

      Rails.logger.info("Unsuccessfully populated organisation " \
        "#{current_user_org.id} from existing Salesforce account " \
          "#{in_mem_orgs.first.salesforce_account_id}. " \
            "Org chosen was incomplete.")

    end

    return nil

  end

  # Takes a Restforce::Collection containing Salesforce accounts, and
  # returns the same collection as populated Organisations objects
  #
  # Maintains order of the Restforce::Collection. So that the latest org is
  # first.
  #
  # @params [retrieved_orgs] Restforce::Collection Contains Salesforce accounts
  # @return [org_array] Array Array of populated Organisation objects
  #
  def convert_salesforce_account_collection_to_organisations(retrieved_orgs)

    org_array  = []

    retrieved_orgs.each do |restforce_org|

      org = Organisation.new()
      populate_organisation_from_restforce_object(org, restforce_org)

      # Populate additional attributes not covered by common function.
      org.salesforce_account_id = restforce_org.Id
      org.org_type = :unknown

      org_array.push(org)
    end

    org_array

  end

end
