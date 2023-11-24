class Project < ApplicationRecord
    include ActiveModel::Validations, GenericValidator
    self.implicit_order_column = "created_at"

    belongs_to :user

    belongs_to :funding_application, optional: true

    has_one :organisation, through: :user

    has_many :released_forms
    has_many :cash_contributions
    has_many :non_cash_contributions
    has_many :project_costs
    has_many :volunteers
    has_many :evidence_of_support

    has_one_attached :capital_work_file
    has_one_attached :governing_document_file
    has_many_attached :accounts_files

    accepts_nested_attributes_for :cash_contributions,
                                  :non_cash_contributions,
                                  :project_costs,
                                  :volunteers,
                                  :evidence_of_support

    validates_associated :cash_contributions, if: :validate_cash_contributions?
    validates_associated :non_cash_contributions, if: :validate_non_cash_contributions?
    validates_associated :project_costs, if: :validate_project_costs?
    validates_associated :volunteers, if: :validate_volunteers?
    validates_associated :evidence_of_support, if: :validate_evidence_of_support?

    attr_accessor :validate_title
    attr_accessor :validate_start_and_end_dates
    attr_accessor :validate_same_location
    attr_accessor :validate_address
    attr_accessor :validate_capital_work
    attr_accessor :validate_permission_type
    attr_accessor :validate_permission_description_yes
    attr_accessor :validate_permission_description_x_not_sure
    attr_accessor :validate_description
    attr_accessor :validate_difference
    attr_accessor :validate_matter
    attr_accessor :validate_heritage_description
    attr_accessor :validate_best_placed_description
    attr_accessor :validate_involvement_description
    attr_accessor :validate_other_outcomes
    attr_accessor :validate_project_costs
    attr_accessor :validate_has_associated_project_costs
    attr_accessor :validate_cash_contributions
    attr_accessor :validate_non_cash_contributions
    attr_accessor :validate_evidence_of_support
    attr_accessor :validate_volunteers
    attr_accessor :validate_cash_contributions_question
    attr_accessor :validate_non_cash_contributions_question
    attr_accessor :validate_check_your_answers
    attr_accessor :validate_governing_document_file
    attr_accessor :validate_accounts_files
    attr_accessor :validate_confirm_declaration
    attr_accessor :validate_is_partnership
    attr_accessor :validate_partnership_details

    # These attributes are used to set individual error messages
    # for each of the project date input fields
    attr_accessor :start_date_day
    attr_accessor :start_date_month
    attr_accessor :start_date_year
    attr_accessor :end_date_day
    attr_accessor :end_date_month
    attr_accessor :end_date_year

    attr_accessor :cash_contributions_question
    attr_accessor :non_cash_contributions_question

    attr_accessor :same_location

    attr_accessor :permission_description_yes
    attr_accessor :permission_description_x_not_sure

    attr_accessor :confirm_declaration

    validates :project_title, presence: true, length: { maximum: 255 }, if: :validate_title?
    validates :start_date_day, presence: true, if: :validate_start_and_end_dates?
    validates :start_date_month, presence: true, if: :validate_start_and_end_dates?
    validates :start_date_year, presence: true, if: :validate_start_and_end_dates?
    validates :end_date_day, presence: true, if: :validate_start_and_end_dates?
    validates :end_date_month, presence: true, if: :validate_start_and_end_dates?
    validates :end_date_year, presence: true, if: :validate_start_and_end_dates?

    validates_with ProjectValidator, if: :validate_no_errors && :validate_start_and_end_dates?

    validates :project_title, presence: true, length: { maximum: 255 }, if: :validate_title?
    validates :same_location, presence: true, if: :validate_same_location?
    validates :line1, presence: true, if: :validate_address?
    validates :townCity, presence: true, if: :validate_address?
    validates :county, presence: true, if: :validate_address?
    validates :postcode, presence: true, if: :validate_address?
    validates :same_location, presence: true, if: :validate_same_location?
    validates_inclusion_of :capital_work, in: [true, false], if: :validate_capital_work?
    validates :permission_type, presence: true, if: :validate_permission_type?
    validates :permission_description_yes, presence: true, if: :validate_permission_description_yes?
    validates :permission_description_x_not_sure, presence: true, if: :validate_permission_description_x_not_sure?
    validates :description, presence: true, if: :validate_description?
    validates :involvement_description, presence: true, if: :validate_involvement_description?
    validates :project_costs, presence: true, if: :validate_has_associated_project_costs?
    validates_inclusion_of :cash_contributions_question,
                           in: ["true", "false"],
                           if: :validate_cash_contributions_question?
    validates_inclusion_of :non_cash_contributions_question,
                           in: ["true", "false"],
                           if: :validate_non_cash_contributions_question?
    validates_inclusion_of :is_partnership, in: [true, false], if: :validate_is_partnership?
    validates :partnership_details, presence: true, if: :validate_partnership_details?
    validates_inclusion_of :confirm_declaration,
                           in: ["true"],
                           if: :validate_confirm_declaration?

    # Mandatory validation on 'Check your answers' page
    validates :description, presence: true, if: :validate_check_your_answers?
    validates :involvement_description, presence: true, if: :validate_check_your_answers?
    validates :project_costs, presence: true, if: :validate_check_your_answers?

    validate do
        validate_length(
            :description,
            500,
            I18n.t("activerecord.errors.models.project.attributes.description.too_long")
        ) if validate_description?
    end

    validate do
        validate_length(
            :permission_description_yes,
            300,
            "Description must be 300 words or fewer"
        ) if validate_permission_description_yes?
    end

    validate do
        validate_length(
            :permission_description_x_not_sure,
            300,
            "Description must be 300 words or fewer"
        ) if validate_permission_description_x_not_sure?
    end

    validate do
        validate_length(
            :difference,
            500,
            I18n.t("activerecord.errors.models.project.attributes.difference.too_long")
        ) if validate_difference?
    end

    validate do
        validate_length(
            :matter,
            500,
            I18n.t("activerecord.errors.models.project.attributes.matter.too_long")
        ) if validate_matter?
    end

    validate do
        validate_length(
            :heritage_description,
            500,
            I18n.t("activerecord.errors.models.project.attributes.heritage_description.too_long")
        ) if validate_heritage_description?
    end

    validate do
        validate_length(
            :best_placed_description,
            500,
            I18n.t("activerecord.errors.models.project.attributes.best_placed_description.too_long")
        ) if validate_best_placed_description?
    end

    validate do
        validate_length(
            :involvement_description,
            300,
            I18n.t("activerecord.errors.models.project.attributes.involvement_description.too_long")
        ) if validate_involvement_description?
    end

    validate do
        for i in 2..9 do
            validate_length(
                "outcome_#{i}_description",
                300,
                I18n.t("activerecord.errors.models.project.attributes.outcome_description.too_long")
            ) if validate_other_outcomes?
        end
    end

    validate do
        validate_file_attached(
            :governing_document_file,
            I18n.t("activerecord.errors.models.project.attributes.governing_document_file.inclusion")
        ) if validate_governing_document_file?
    end

    validate do
        validate_file_attached(
            :accounts_files,
            I18n.t("activerecord.errors.models.project.attributes.accounts_files.inclusion")
        ) if validate_accounts_files?
    end

    def validate_title?
        validate_title == true
    end

    def validate_start_and_end_dates?
        validate_start_and_end_dates == true
    end

    def validate_no_errors?
        self.errors.empty?
    end

    def validate_same_location?
        validate_same_location == true
    end

    def validate_address?
        validate_address == true
    end

    def validate_capital_work?
        validate_capital_work == true
    end

    def validate_permission_type?
        validate_permission_type == true
    end

    def validate_permission_description_yes?
        validate_permission_description_yes == true
    end

    def validate_permission_description_x_not_sure?
        validate_permission_description_x_not_sure == true
    end

    def validate_description?
        validate_description == true
    end

    def validate_difference?
        validate_difference == true
    end

    def validate_matter?
        validate_matter == true
    end

    def validate_heritage_description?
        validate_heritage_description == true
    end

    def validate_best_placed_description?
        validate_best_placed_description == true
    end

    def validate_involvement_description?
        validate_involvement_description == true
    end

    def validate_other_outcomes?
        validate_other_outcomes == true
    end

    def validate_project_costs?
        validate_project_costs == true
    end

    def validate_has_associated_project_costs?
        validate_has_associated_project_costs == true
    end

    def validate_cash_contributions_question?
        validate_cash_contributions_question == true
    end

    def validate_cash_contributions?
        validate_cash_contributions == true
    end

    def validate_non_cash_contributions_question?
        validate_non_cash_contributions_question == true
    end

    def validate_non_cash_contributions?
        validate_non_cash_contributions == true
    end

    def validate_evidence_of_support?
        validate_evidence_of_support == true
    end

    def validate_volunteers?
        validate_volunteers == true
    end

    def validate_check_your_answers?
        validate_check_your_answers == true
    end

    def validate_governing_document_file?
        validate_governing_document_file == true
    end

    def validate_accounts_files?
        validate_accounts_files == true
    end

    def validate_confirm_declaration?
        validate_confirm_declaration == true
    end

    def validate_is_partnership?
        validate_is_partnership == true
    end

    def validate_partnership_details?
        validate_partnership_details == true
    end

    enum permission_type: {
        yes: 0,
        no: 1,
        x_not_sure: 2
    }

    def to_salesforce_json
        setAddressLines = -> (line1, line2, line3) {
            [line1, line2, line3].compact.join(', ')
        }
        Jbuilder.encode do |json|
            json.ignore_nil!
            json.meta do
                json.set!('applicationId', self.id)
                json.set!('form', "3-10k-grant")
                json.set!('schemaVersion', "v1.x")
                json.set!('startedAt', self.created_at)
                json.set!('username', self.user.email)
            end
            json.application do
                json.set!('projectName', self.project_title)
                json.projectDateRange do
                    json.startDate self.start_date
                    json.endDate self.end_date
                end
                json.set!('mainContactName', self.user.name)
                json.set!('mainContactDateOfBirth', self.user.date_of_birth)
                json.set!('mainContactEmail', self.user.email)
                json.set!('mainContactPhone', self.user.phone_number)
                json.mainContactAddress do
                    json.line1 setAddressLines.call(self.user.line1, self.user.line2, self.user.line3)
                    json.townCity self.user.townCity
                    json.county self.user.county
                    json.postcode self.user.postcode
                end
                json.projectAddress do
                    json.line1 setAddressLines.call(self.line1, self.line2, self.line3)
                    json.county self.county
                    json.townCity self.townCity
                    json.projectPostcode self.postcode
                end
                json.set!('yourIdeaProject', self.description)
                json.set!('projectDifference', self.difference)
                json.set!('projectCommunity', self.matter)
                json.set!('projectOrgBestPlace', self.best_placed_description)
                json.set!('projectAvailable', self.heritage_description)
                json.set!('projectOutcome1', self.involvement_description)
                json.set!('projectOutcome2', self.outcome_2_description)
                json.set!('projectOutcome3', self.outcome_3_description)
                json.set!('projectOutcome4', self.outcome_4_description)
                json.set!('projectOutcome5', self.outcome_5_description)
                json.set!('projectOutcome6', self.outcome_6_description)
                json.set!('projectOutcome7', self.outcome_7_description)
                json.set!('projectOutcome8', self.outcome_8_description)
                json.set!('projectOutcome9', self.outcome_9_description)
                json.set!('projectOutcome2Checked', self.outcome_2)
                json.set!('projectOutcome3Checked', self.outcome_3)
                json.set!('projectOutcome4Checked', self.outcome_4)
                json.set!('projectOutcome5Checked', self.outcome_5)
                json.set!('projectOutcome6Checked', self.outcome_6)
                json.set!('projectOutcome7Checked', self.outcome_7)
                json.set!('projectOutcome8Checked', self.outcome_8)
                json.set!('projectOutcome9Checked', self.outcome_9)
                json.set!('projectNeedsPermission', (self.permission_type == 'x_not_sure' ? 'not_sure' : self.permission_type)&.dasherize)
                json.set!('projectNeedsPermissionDetails', self.permission_description)
                json.set!('keepInformed', self.keep_informed_declaration)
                json.set!('involveInResearch', self.user_research_declaration)
                json.set!('informationNotPubliclyAvailableRequest', self.declaration_reasons_description)
                json.set!('isPartnership', self.is_partnership)
                json.set!('partnershipDetails', self.partnership_details)
                json.set!('projectCapitalWork', self.capital_work)
                json.projectCosts self.project_costs do |project_cost|
                    json.costId project_cost.id
                    json.costType project_cost.cost_type&.dasherize
                    json.costDescription project_cost.description
                    json.costAmount project_cost.amount
                end
                json.projectVolunteers self.volunteers do |volunteer|
                    json.description volunteer.description
                    json.hours volunteer.hours
                end
                json.nonCashContributions self.non_cash_contributions do |non_cash_contribution|
                        json.description non_cash_contribution.description
                        json.estimatedValue non_cash_contribution.amount
                end
                json.cashContributions self.cash_contributions do |cash_contribution|
                        json.description cash_contribution.description
                        json.amount cash_contribution.amount
                        json.secured format_secured_for_salesforce(cash_contribution)
                        json.id cash_contribution.id
                end
                json.set!('organisationSalesforceAccountId', 
                        self.user.organisations.first.salesforce_account_id
                    ) if self.user.organisations.first.salesforce_account_id
                json.set!('organisationId', self.user.organisations.first.id)
                json.set!('organisationName', self.user.organisations.first.name)
                json.set!('organisationType',
                    get_organisation_type_for_salesforce_json)
                json.set!('companyNumber', self.user.organisations.first.company_number)
                json.set!('charityNumber', self.user.organisations.first.charity_number)
                json.organisationAddress do
                    json.line1 setAddressLines.call(self.user.organisations.first.line1, self.user.organisations.first.line2, self.user.organisations.first.line3)
                    json.county self.user.organisations.first.county
                    json.townCity self.user.organisations.first.townCity
                    json.postcode self.user.organisations.first.postcode
                end
            end
        end
    end

    private

        def get_organisation_type_for_salesforce_json
            formatted_org_type_value = case self.user.organisations.first.org_type
            when 'Registered charity'
            'registered-charity'
            when 'Local authority'
            'local-authority'
            when 'Other public sector organisation'
            'other-public-sector-organisation'
            when 'Public Private Company'
            'public-private-company'
            when 'Community Interest Company CIC'
            'community-interest-company'
            when 'Charitable Incorporated Organisation CIO'
            'charitable-incorporated-organisation'
            when 'Partnership or Limited Liability Partnership LLP'
            'partnership-or-llp'
            when 'Private owner of heritage'
            'private-owner-of-heritage'
            when 'Co-operative Society', 'Industrial and Provident Society', 'Registered Societies'
            'cooperative-industrial-provident-registered-society'
            when 'Trust'
            'trust'
            when 'Other constituted group', 'unincorporated club or society'
            'other-constituted-uncorporated-group-or-society'
            when 'None of the above'
            'none-of-the-above'
            else
            self.user.organisations.first.org_type&.dasherize
            end
        
            formatted_org_type_value
        end
      


    # Formats the secured value of a cash contribution for Salesforce.
    #
    # Given a cash contribution with a particular secured value, this method
    # will either return the "not sure" string or a dasherized version of the
    # value, depending on the original value.
    #
    # @param [object] cash contribution object
    # @param [string] :secured for the answer/value of the 'is your cash 
    #                                       contribution secured?' question
    #
    # @return [string] - A formatted string value. Either 'not sure' or
    #                                              a dasherized value   
    def format_secured_for_salesforce(cash_contribution)
        if cash_contribution.secured == 'x_not_sure'
          'not sure'
        else
          cash_contribution.secured&.dasherize
        end
    end
end