class Organisation < ApplicationRecord
  include ActiveModel::Validations, GenericValidator, OrganisationHelper

  after_find do |organisation|

    unless organisation.updated_at.today? || organisation.salesforce_account_id.nil? \
      || salesforce_checked_today?(organisation)

      Rails.logger.info "Checking and updating Org with id: #{organisation.id}"
      update_existing_organisation_from_salesforce_details(organisation)

    end 
  end

  self.implicit_order_column = "created_at"

  has_many :pre_applications
  has_many :funding_applications

  has_many :organisations_org_types, inverse_of: :organisation
  has_many :org_types, through: :organisations_org_types

  has_many :users_organisations, inverse_of: :organisation
  has_many :users, through: :users_organisations

  has_many_attached :governing_document_file


  accepts_nested_attributes_for :organisations_org_types, allow_destroy: true

  attr_accessor :has_custom_org_type

  attr_accessor :validate_name
  attr_accessor :validate_org_type
  attr_accessor :validate_custom_org_type
  attr_accessor :validate_address
  attr_accessor :validate_board_members_or_trustees
  attr_accessor :validate_vat_registered
  attr_accessor :validate_vat_number
  attr_accessor :validate_company_number
  attr_accessor :validate_charity_number
  attr_accessor :validate_main_purpose_and_activities
  attr_accessor :validate_communities_that_org_serve
  attr_accessor :validate_leadership_self_identify
  attr_accessor :validate_number_of_employees
  attr_accessor :validate_number_of_volunteers
  attr_accessor :validate_volunteer_work_description
  attr_accessor :has_charity_number
  attr_accessor :has_company_number
  attr_accessor :has_board_members_or_trustees
  attr_accessor :has_number_of_employees
  attr_accessor :has_number_of_volunteers
  attr_accessor :validate_governing_documents
  attr_accessor :validate_governing_document_file
  attr_accessor :wants_to_upload_document

  validates :org_type, presence: true, if: :validate_org_type?
  validates :custom_org_type, presence: true, if: -> { org_type == 'other' && :validate_custom_org_type? }
  validates :custom_org_type, length: { maximum: 255 }
  validates :name, presence: true, if: :validate_name?
  validates :name, length: { maximum: 255 }
  validates :main_purpose_and_activities, presence: true, if: :validate_main_purpose_and_activities?
  validates :communities_that_org_serve, presence: true, if: :validate_communities_that_org_serve?
  validates :leadership_self_identify, presence: true, if: :validate_leadership_self_identify?
  validates :line1, presence: true, if: :validate_address?
  validates :townCity, presence: true, if: :validate_address?
  validates :county, presence: true, if: :validate_address?
  validates :postcode, presence: true, if: :validate_address?
  validates :company_number, presence: { message: I18n.t('company_number.errors.text_field_blank') }, if: -> { company_number_required? && :validate_company_number? }
  validates :charity_number, presence: { message: I18n.t('charity_number.errors.text_field_blank') }, if: -> { charity_number_required? && :validate_charity_number? }
  validates :board_members_or_trustees, presence: true, if: :validate_board_members_or_trustees?
  validates :board_members_or_trustees, numericality: {
    greater_than: -1,
    less_than: 2147483648,
    allow_nil: true,
  }, if: -> { :validate_board_members_or_trustees? && board_members_or_trustees_required?}
  validates_inclusion_of :vat_registered, in: [true, false], if: :validate_vat_registered?
  validates :vat_number, length: { minimum: 9, maximum: 12 }, if: :validate_vat_number?
  validates :company_number, length: { maximum: 20, message: I18n.t('company_number.errors.too_long') }, if: -> { company_number_required? && :validate_company_number? }
  validates :charity_number, length: { maximum: 20, message: I18n.t('charity_number.errors.too_long') }, if: -> { charity_number_required? && :validate_charity_number? }
  validates :number_of_employees, presence: { message: I18n.t('number_of_employees.errors.text_field_blank') }, if: -> { number_of_employees_required? && :validate_number_of_employees? }
  validates :number_of_volunteers, presence: { message: I18n.t('number_of_volunteers.errors.text_field_blank') }, if: -> { number_of_volunteers_required? && :validate_number_of_volunteers? }
  validates :volunteer_work_description, presence: true, if: :validate_volunteer_work_description?
 

  validate do

    validate_length(
      :main_purpose_and_activities,
      500,
      I18n.t('activerecord.errors.models.organisation.attributes.main_purpose_and_activities.too_long', word_count: 500)
    ) if validate_main_purpose_and_activities?

    validate_length(
      :volunteer_work_description,
      500,
      I18n.t('activerecord.errors.models.organisation.attributes.volunteer_work_description.too_long', word_count: 500)
    ) if validate_volunteer_work_description?

  end

  def custom_org_type_presence
    if custom_org_type.blank?
      errors.add(:custom_org_type, "can't be blank")
    end
  end

  def charity_number_required?
    has_charity_number == "yes"
  end

  def company_number_required?
    has_company_number == "yes"
  end

  def board_members_or_trustees_required?
    has_board_members_or_trustees == "yes"
  end

  def number_of_employees_required?
    has_number_of_employees == "yes"
  end

  def number_of_volunteers_required?
    has_number_of_volunteers == "yes"
  end

  def validate_name?
    validate_name == true
  end

  def validate_org_type?
    validate_org_type == true
  end

  def validate_custom_org_type?
    validate_custom_org_type == true
  end

  def validate_address?
    validate_address == true
  end

  def validate_board_members_or_trustees?
    validate_board_members_or_trustees == true
  end
  
  def validate_vat_number?
    validate_vat_number == true
  end

  def validate_company_number?
    validate_company_number == true
  end

  def validate_charity_number?
    validate_charity_number == true
  end

  def validate_vat_registered?
    validate_vat_registered == true
  end

  def validate_main_purpose_and_activities? 
    validate_main_purpose_and_activities == true
  end

  def validate_communities_that_org_serve?
    validate_communities_that_org_serve == true
  end

  def validate_leadership_self_identify?
    validate_leadership_self_identify == true
  end

  def validate_number_of_employees?
    validate_number_of_employees == true
  end

  def validate_number_of_volunteers?
    validate_number_of_volunteers == true
  end

  def validate_volunteer_work_description?
    validate_volunteer_work_description == true
  end

  def validate_governing_documents?
    validate_governing_documents == true
  end

  def validate_governing_document_file?
    validate_governing_document_file == true
  end


  # Equality function.
  # Compares two organisation based on the attributes that FFE would normally
  # consider mandatory when capturing organisation information before applying
  # for a grant.  Medium grant attributes ignores as they vary per application.
  # @param [other] Organisation The Organisation to compare to self.
  # @return [true/false] Boolean Returns true for a match
  def == (other)
    self.name&.strip&.downcase == other.name&.strip&.downcase &&
    self.org_type&.strip&.downcase == other.org_type&.strip&.downcase &&
    self.line1&.strip&.downcase == other.line1&.strip&.downcase &&
    self.townCity&.strip&.downcase == other.townCity&.strip&.downcase &&
    self.county&.strip&.downcase == other.county&.strip&.downcase &&
    self.postcode&.strip&.downcase == other.postcode&.strip&.downcase &&
    self.company_number&.strip&.downcase == other.company_number&.strip&.downcase &&
    self.charity_number&.strip&.downcase == other.charity_number&.strip&.downcase
  end

  # Org types are set when an applicant initially completes organisation
  # details (The organisation_org_types table has not been used.)
  #
  # The partial, that captures the org types, only shows orgs from 1 to 10
  # 10 is 'other_public_sector_organisation' and the last type a user
  # can select. So any additional org types will require changes in these
  # partials.  And new translations for the application, pre-application,
  # and organisation summary screens.
  #
  # Salesforce merges some org types upon submission like:
  # - Faith based or church organisation (instead of faith or church)
  # - Community of Voluntary group (instead of community or voluntary group)
  # - Registered company or Community Interest Company (instead of reg or com)
  #
  # Future work intends to address this, so changes to an organisation type in
  # Salesforce can be reflected in what FFE stores,
  # when after_find runs above.
  #
  # For cases being imported from GEMS, a new type of unknown as been added.
  # This should be used when FFE can't understand the org type being used.
  #
  enum org_type: {
      registered_charity: 0,
      local_authority: 1,
      registered_company: 2,
      community_interest_company: 3,
      faith_based_organisation: 4,
      church_organisation: 5,
      community_group: 6,
      voluntary_group: 7,
      individual_private_owner_of_heritage: 8,
      other: 9,
      other_public_sector_organisation: 10,
      unknown: 11,
      public_or_private_company: 12,
      charitable_incorporated_organisation: 13,
      partnership_or_llp: 14,
      cooperative_industrial_provident_registered_society: 15,
      trust: 16,
      other_constituted_unincorporated_club_or_society: 17
  }

end
